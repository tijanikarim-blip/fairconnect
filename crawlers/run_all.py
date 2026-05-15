"""
FairConnect Data Acquisition Pipeline
Runs all spiders sequentially to build the trade show database.

Usage:
    python run_all.py                          # Run all spiders
    python run_all.py --spider 10times         # Run specific spider
    python run_all.py --export output.json     # Export to JSON as well
"""
import argparse
import logging
import os
import sys
from scrapy.crawler import CrawlerProcess
from scrapy.utils.project import get_project_settings

sys.path.insert(0, "..")

_SERVICE_ACCOUNT_PATH = os.path.join(os.path.dirname(__file__), "service-account.json")
if os.path.exists(_SERVICE_ACCOUNT_PATH):
    os.environ.setdefault("FIREBASE_CREDENTIALS", _SERVICE_ACCOUNT_PATH)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(name)s] %(levelname)s: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger("crawler-runner")

SPIDERS = {
    "10times": ("spiders.tentimes_spider", "TentimesSpider"),
    "eventseye": ("spiders.eventseye_spider", "EventsEyeSpider"),
    "tradefairdates": ("spiders.tradefairdates_spider", "TradeFairDatesSpider"),
    "tsnn": ("spiders.tsnn_spider", "TsnnSpider"),
    "ufi": ("spiders.ufi_spider", "UfiSpider"),
}

ALL_SPIDERS = list(SPIDERS.keys())


def import_spider_class(name):
    mod_path, cls_name = SPIDERS[name]
    import importlib
    mod = importlib.import_module(mod_path, package="crawlers")
    return getattr(mod, cls_name)


def main():
    parser = argparse.ArgumentParser(description="FairConnect Trade Show Crawler")
    parser.add_argument(
        "--spider",
        choices=ALL_SPIDERS + ["all"],
        default="all",
        help="Spider to run (default: all)",
    )
    parser.add_argument("--export", help="Export results to JSON file")
    args = parser.parse_args()

    settings = get_project_settings()

    if args.export:
        settings.set("FEEDS", {
            args.export: {
                "format": "json",
                "encoding": "utf-8",
                "indent": 2,
            }
        })

    process = CrawlerProcess(settings)

    spiders = ALL_SPIDERS if args.spider == "all" else [args.spider]

    for name in spiders:
        cls = import_spider_class(name)
        logger.info(f"=" * 60)
        logger.info(f"Starting spider: {name}")
        logger.info(f"=" * 60)
        try:
            process.crawl(cls)
        except Exception as e:
            logger.error(f"Spider {name} failed: {e}")

    logger.info("Starting crawl process...")
    process.start()
    logger.info("All spiders completed.")


if __name__ == "__main__":
    main()
