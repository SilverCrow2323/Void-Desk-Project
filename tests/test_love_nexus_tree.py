from pathlib import Path
import unittest


class LoveNexusTreeIntegrationTests(unittest.TestCase):
    def test_tree_overlay_is_drawn_before_planets(self):
        source = (Path(__file__).resolve().parents[1] / "love" / "scenes" / "nexus.lua").read_text(encoding="utf-8")
        self.assertIn("local TREE_EDGES", source)
        self.assertIn("draw_tree_branches(warp_dim)", source)
        self.assertLess(source.index("draw_tree_branches(warp_dim)"), source.index("-- Sort for depth"))

    def test_topology_uses_stable_nexus_node_ids(self):
        source = (Path(__file__).resolve().parents[1] / "love" / "scenes" / "nexus.lua").read_text(encoding="utf-8")
        for edge in ("{0,3}", "{0,5}", "{3,4}", "{5,12}", "{6,8}", "{9,14}"):
            self.assertIn(edge, source)


if __name__ == "__main__":
    unittest.main()
