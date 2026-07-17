import pytest
from fastapi.testclient import TestClient

from api.main import app


@pytest.fixture(scope="session")
def client() -> TestClient:
    """
    In-process test client for the FastAPI app.

    Requires a reachable PostgreSQL instance configured via the
    DATABASE_URL environment variable (see docker-compose.yml and
    .github/workflows/ci.yml for how this is wired up in CI).
    """
    return TestClient(app)
