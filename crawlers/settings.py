BOT_NAME = "fairconnect_crawler"

SPIDER_MODULES = ["crawlers.spiders"]
NEWSPIDER_MODULE = "crawlers.spiders"

ROBOTSTXT_OBEY = True

CONCURRENT_REQUESTS = 16
DOWNLOAD_DELAY = 1.5
RANDOMIZE_DOWNLOAD_DELAY = True

COOKIES_ENABLED = False

ITEM_PIPELINES = {
    "crawlers.pipelines.cleaning_pipeline.CleaningPipeline": 200,
    "crawlers.pipelines.firestore_pipeline.FirestorePipeline": 300,
}

REQUEST_FINGERPRINTER_IMPLEMENTATION = "2.7"

TWISTED_REACTOR = "twisted.internet.asyncioreactor.AsyncioReactor"

FEED_EXPORT_ENCODING = "utf-8"

DEFAULT_REQUEST_HEADERS = {
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "en",
    "User-Agent": "FairConnectBot/1.0 (+https://fairconnect.app)",
}
