"""
Performance tests: response time under a simple, single-request
threshold. Not a substitute for real load testing (e.g. k6, Locust) —
this only guards against obvious regressions (missing index, N+1
queries, etc.) in CI.
"""
import time

MAX_RESPONSE_TIME_SECONDS = 1.0


def test_health_responds_within_threshold(client):
    start = time.monotonic()
    response = client.get("/health")
    elapsed = time.monotonic() - start

    assert response.status_code == 200
    assert elapsed < MAX_RESPONSE_TIME_SECONDS


def test_list_results_responds_within_threshold(client):
    start = time.monotonic()
    response = client.get("/results", params={"limit": 50})
    elapsed = time.monotonic() - start

    assert response.status_code == 200
    assert elapsed < MAX_RESPONSE_TIME_SECONDS


def test_stats_responds_within_threshold(client):
    start = time.monotonic()
    response = client.get("/stats")
    elapsed = time.monotonic() - start

    assert response.status_code == 200
    assert elapsed < MAX_RESPONSE_TIME_SECONDS
