import unittest

from desk.nexus_tree import TREE_EDGES, branch_points


class NexusLifeTreeTests(unittest.TestCase):
    def test_branch_endpoints_are_preserved(self):
        points = branch_points((10, 20), (180, 90), edge_index=2)
        self.assertEqual(points[0], (10, 20))
        self.assertEqual(points[-1], (180, 90))
        self.assertEqual(len(points), 13)

    def test_branch_curve_is_deterministic_and_bends(self):
        a = branch_points((0, 0), (100, 0), edge_index=0)
        b = branch_points((0, 0), (100, 0), edge_index=0)
        self.assertEqual(a, b)
        self.assertTrue(any(y != 0 for _x, y in a[1:-1]))

    def test_branch_topology_covers_visible_destinations(self):
        edges = set(TREE_EDGES)
        self.assertEqual(len(edges), len(TREE_EDGES))
        self.assertIn((0, 3), edges)
        self.assertIn((0, 5), edges)
        self.assertIn((3, 4), edges)
        self.assertIn((5, 12), edges)
        self.assertIn((6, 8), edges)
        nodes = {node for edge in TREE_EDGES for node in edge}
        self.assertEqual(nodes, set(range(14)))

    def test_invalid_segment_count_is_rejected(self):
        with self.assertRaises(ValueError):
            branch_points((0, 0), (1, 1), segments=1)


if __name__ == "__main__":
    unittest.main()
