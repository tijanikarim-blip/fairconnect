import random
import time
from scrapy import signals
from scrapy.http import HtmlResponse
from urllib.parse import urlparse


REAL_USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Safari/605.1.15",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:127.0) Gecko/20100101 Firefox/127.0",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 14.5; rv:127.0) Gecko/20100101 Firefox/127.0",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36 Edg/125.0.0.0",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36",
    "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1",
    "Mozilla/5.0 (iPad; CPU OS 17_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 Safari/604.1",
]


class RotateUserAgentMiddleware:
    def process_request(self, request, spider):
        request.headers["User-Agent"] = random.choice(REAL_USER_AGENTS)
        request.headers["X-Forwarded-For"] = self._random_ip()

    def _random_ip(self):
        return f"{random.randint(10, 223)}.{random.randint(0, 255)}.{random.randint(0, 255)}.{random.randint(1, 254)}"


class RetryWithBackoffMiddleware:
    def process_response(self, request, response, spider):
        if response.status in [403, 429, 503]:
            retries = request.meta.get("retry_times", 0) + 1
            if retries <= spider.settings.getint("RETRY_TIMES", 3):
                backoff = 2 ** retries + random.uniform(0, 1)
                spider.logger.info(f"Backoff {backoff}s for {request.url} (retry {retries})")
                time.sleep(backoff)
                new_request = request.copy()
                new_request.meta["retry_times"] = retries
                new_request.dont_filter = True
                return new_request
        return response


class CloudflareBypassMiddleware:
    def process_response(self, request, response, spider):
        body_lower = response.text.lower() if response.text else ""

        is_blocked = (
            response.status in [403, 503]
            or "checking your browser" in body_lower
            or "just a moment" in body_lower
            or "please enable cookies" in body_lower
            or "attention required" in body_lower
            or "cloudflare" in body_lower and "challenge" in body_lower
        )

        if is_blocked:
            spider.logger.warning(f"Cloudflare block detected on {request.url}")
            try:
                return self._bypass_with_cloudscraper(request, spider)
            except ImportError:
                spider.logger.warning("cloudscraper not available, trying selenium fallback")
                try:
                    return self._bypass_with_selenium(request, spider)
                except ImportError:
                    spider.logger.warning("selenium not available either, giving up")
                    return response

        return response

    def _bypass_with_cloudscraper(self, request, spider):
        import cloudscraper
        scraper = cloudscraper.create_scraper(
            browser={
                "browser": "chrome",
                "platform": "windows",
                "mobile": False,
            }
        )
        headers = {k.decode(): v.decode() for k, v in request.headers.items()}
        headers["User-Agent"] = random.choice(REAL_USER_AGENTS)
        resp = scraper.get(
            request.url,
            headers=headers,
            timeout=30,
            allow_redirects=True,
        )
        return HtmlResponse(
            url=resp.url,
            status=resp.status_code,
            headers=dict(resp.headers),
            body=resp.content,
            request=request,
        )

    def _bypass_with_selenium(self, request, spider):
        from selenium import webdriver
        from selenium.webdriver.chrome.options import Options

        options = Options()
        options.add_argument("--headless")
        options.add_argument("--no-sandbox")
        options.add_argument("--disable-dev-shm-usage")
        options.add_argument(f"user-agent={random.choice(REAL_USER_AGENTS)}")

        driver = webdriver.Chrome(options=options)
        try:
            driver.get(request.url)
            time.sleep(5)
            body = driver.page_source
            current_url = driver.current_url
            return HtmlResponse(
                url=current_url,
                status=200,
                body=body,
                encoding="utf-8",
                request=request,
            )
        finally:
            driver.quit()
