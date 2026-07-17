"""Smoke tests: is the service alive and answering at all."""


def test_health_returns_200(client):
    response = client.get("/health")
    assert response.status_code == 200


def test_health_returns_expected_body(client):
    response = client.get("/health")
    assert response.json() == {"status": "ok"}


def test_openapi_schema_is_available(client):
    response = client.get("/openapi.json")
    assert response.status_code == 200
    assert "paths" in response.json()
