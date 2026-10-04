"""Validate the shared wire corpus and protocol expectations, never a live service."""
import json
from pathlib import Path
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

import yaml
from jsonschema import FormatChecker
from openapi_schema_validator import OAS30Validator
from openapi_spec_validator import validate

CONTRACTS = Path(__file__).resolve().parents[1]


def load_contract():
    api = yaml.safe_load((CONTRACTS / 'openapi.yaml').read_text())
    validate(api)
    return api


def load_cases():
    return [case for path in sorted((CONTRACTS / 'fixtures/sync').glob('*.json'))
            for case in json.loads(path.read_text())]


def errors_for(api, schema, body):
    validator = OAS30Validator(
        {'$ref': '#/components/schemas/' + schema, 'components': api['components']},
        format_checker=FormatChecker())
    return list(validator.iter_errors(body))


def paths(error):
    base = '/'.join(str(p) for p in error.absolute_path)
    yield base
    if error.validator == 'additionalProperties' and isinstance(error.instance, dict):
        for key in error.instance.keys() - error.schema.get('properties', {}).keys():
            yield '/'.join(filter(None, (base, key)))
    for child in error.context:
        yield from paths(child)


def require(condition, message):
    if not condition:
        raise ValueError(message)


def verify_cases(api, cases):
    index = {c['name']: c for c in cases}
    require(len(index) == len(cases), 'duplicate fixture name')
    for case in cases:
        name, schema, body = case['name'], case['schema'], case['body']
        errors = errors_for(api, schema, body)
        require(bool(errors) != case['valid'], f'{name}: schema expectation failed: {errors}')
        if not case['valid']:
            expected = case['errorPath']
            require(any(p == expected or p.startswith(expected + '/')
                        for e in errors for p in paths(e)), f'{name}: expected error at {expected}')
            continue
        if schema == 'PushRequest':
            ids = [o['operationId'] for o in body['operations']]
            require(len(ids) == len(set(ids)), f'{name}: duplicate operation IDs')
            for op in body['operations']:
                try:
                    ZoneInfo(op['timezone'])
                except (ZoneInfoNotFoundError, ValueError) as exc:
                    raise ValueError(f'{name}: invalid IANA timezone') from exc
        if 'http' in case:
            http = case['http']
            endpoint = api['paths'][http['path']][http['method'].lower()]
            response = endpoint['responses'][str(http['status'])]
            media = http['headers']['Content-Type']
            wire_ref = response['content'][media]['schema']['$ref'].split('/')[-1]
            require(wire_ref == schema, f'{name}: endpoint response schema mismatch')
            if schema == 'Problem':
                require(body['status'] == http['status'], f'{name}: problem status mismatch')
            if http['status'] == 401:
                require(http['headers'].get('WWW-Authenticate') == 'Bearer', f'{name}: auth header')
            if http['status'] == 429:
                require(int(http['headers'].get('Retry-After', '0')) > 0, f'{name}: retry header')
        if 'requestCase' in case:
            request = index[case['requestCase']]['body']
            ids = [o['operationId'] for o in request['operations']]
            require([r['operationId'] for r in body['results']] == ids, f'{name}: result IDs')
            applied = [r['operationId'] for r in body['results'] if r['status'] == 'applied']
            pending = [i for i in ids if i not in applied]
            require(applied == case['acknowledged'] and pending == case['pending'], f'{name}: ack policy')
        if 'replayOf' in case:
            require(body['results'] == index[case['replayOf']]['body']['results'], f'{name}: replay changed ack')
        if schema == 'SnapshotResponse':
            require((body['nextPageToken'] is not None) == body['hasMore']
                    and ((body['nextCursor'] is None) == body['hasMore']), f'{name}: snapshot pagination')
            if not body['hasMore']:
                require(body['nextCursor'] == body['checkpoint'], f'{name}: checkpoint continuation')
        if 'previousPage' in case:
            previous = index[case['previousPage']]['body']
            require(all(body[k] == previous[k] for k in ('snapshotId', 'checkpoint', 'capturedAt')),
                    f'{name}: snapshot identity')
        if 'snapshotPage' in case:
            previous = index[case['snapshotPage']]['body']
            require(not previous['hasMore'] and previous['nextCursor'] == previous['checkpoint'],
                    f'{name}: resume before snapshot complete')
    return len(cases)


if __name__ == '__main__':
    print(f'Validated OpenAPI and {verify_cases(load_contract(), load_cases())} shared fixtures.')
