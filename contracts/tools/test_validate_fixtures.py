import copy
import unittest
from validate_fixtures import load_contract, load_cases, errors_for, verify_cases


class ContractValidationTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.api = load_contract()
        cls.cases = load_cases()

    def test_shared_corpus_and_protocol_expectations(self):
        self.assertGreaterEqual(verify_cases(self.api, self.cases), 30)

    def test_required_field_and_uuid_are_checked_inside_references(self):
        request = copy.deepcopy(next(c['body'] for c in self.cases if c['name'] == 'mixed-request'))
        del request['operations'][0]['operationId']
        self.assertTrue(errors_for(self.api, 'PushRequest', request))
        request['operations'][0]['operationId'] = 'not-a-uuid'
        self.assertTrue(errors_for(self.api, 'PushRequest', request))

    def test_corrupted_ack_cannot_discard_pending_items(self):
        cases = copy.deepcopy(self.cases)
        response = next(c for c in cases if c['name'] == 'mixed-response')
        response['body']['results'].pop()
        with self.assertRaisesRegex(ValueError, 'result IDs'):
            verify_cases(self.api, cases)

    def test_snapshot_cannot_publish_cursor_before_last_page(self):
        cases = copy.deepcopy(self.cases)
        first = next(c for c in cases if c['name'] == 'snapshot-first')
        first['body']['nextCursor'] = first['body']['checkpoint']
        with self.assertRaisesRegex(ValueError, 'snapshot pagination'):
            verify_cases(self.api, cases)

    def test_snapshot_checkpoint_cannot_change_between_pages(self):
        cases = copy.deepcopy(self.cases)
        last = next(c for c in cases if c['name'] == 'snapshot-last')
        last['body']['checkpoint'] = 'other_checkpoint'
        last['body']['nextCursor'] = 'other_checkpoint'
        with self.assertRaisesRegex(ValueError, 'snapshot identity'):
            verify_cases(self.api, cases)


if __name__ == '__main__':
    unittest.main()
