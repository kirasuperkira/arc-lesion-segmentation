def test_unknown_subject_returns_404(client):
    response = client.get("/results/sub-DOES-NOT-EXIST")
    assert response.status_code == 404

def test_unknown_subject_error_body_mentions_subject(client):
    response = client.get("/results/sub-DOES-NOT-EXIST")
    assert "sub-DOES-NOT-EXIST" in response.json()["detail"]

def test_limit_zero_is_rejected(client):
    response = client.get("/results", params={"limit": 0})
    assert response.status_code == 422

def test_limit_above_max_is_rejected(client):
    response = client.get("/results", params={"limit": 100000})
    assert response.status_code == 422

def test_negative_offset_is_rejected(client):
    response = client.get("/results", params={"offset": -1})
    assert response.status_code == 422

def test_non_numeric_limit_is_rejected(client):
    response = client.get("/results", params={"limit": "abc"})
    assert response.status_code == 422