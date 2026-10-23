"""Maintain parity between the six self-contained platform/language packages."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
PACKAGES = [(language, platform) for language in ("EN", "TR") for platform in ("Windows", "Linux", "macOS")]
EXPECTED_VERSION = "graphifyy[mcp,watch]==0.9.94"


class DistributionParityTests(unittest.TestCase):
    def test_single_mcp_proxy_implementation(self):
        copies = [(language, platform, (ROOT / language / platform / "graphify-mcp-proxy.py").read_bytes())
                  for language, platform in PACKAGES]
        baseline = copies[0][2]
        for language, platform, payload in copies:
            with self.subTest(language=language, platform=platform):
                self.assertEqual(payload, baseline)

    def test_all_new_installers_pin_validated_dependency(self):
        for language, platform in PACKAGES:
            with self.subTest(language=language, platform=platform):
                folder = ROOT / language / platform
                suffix = "ps1" if platform == "Windows" else "sh"
                self.assertIn(EXPECTED_VERSION, (folder / f"setup-ai-context.{suffix}").read_text(encoding="utf-8-sig"))
                self.assertIn(EXPECTED_VERSION, (folder / "cloud" / "setup.sh").read_text(encoding="utf-8"))

    def test_all_installers_default_optional_integrations_off(self):
        for language, platform in PACKAGES:
            with self.subTest(language=language, platform=platform):
                folder = ROOT / language / platform
                script = (folder / ("setup-ai-context.ps1" if platform == "Windows" else "setup-ai-context.sh")).read_text(encoding="utf-8-sig")
                self.assertIn("EnableWatcher" if platform == "Windows" else "enable_watcher=0", script)
                self.assertIn("EnableLaravelBoost" if platform == "Windows" else "enable_boost=0", script)


if __name__ == "__main__":
    unittest.main()
