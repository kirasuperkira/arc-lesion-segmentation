"""Functional tests: does the API return correct data and correct shapes."""


def test_list_results_returns_a_list(client):
    response = client.get("/results")
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_list_results_content_type_is_json(client):
    response = client.get("/results")
    assert response.headers["content-type"].startswith("application/json")


def test_list_results_respects_limit(client):
    response = client.get("/results", params={"limit": 5})
    assert response.status_code == 200
    assert len(response.json()) <= 5


def test_participant_item_has_expected_fields(client):
    response = client.get("/results", params={"limit": 1})
    results = response.json()
    if not results:
        return  # empty DB in this environment — nothing to assert on
    item = results[0]
    for field in ("subject_code", "dice_score", "lesion_volume_gt", "lesion_volume_auto"):
        assert field in item


def test_get_existing_participant_returns_matching_subject(client):
    listing = client.get("/results", params={"limit": 1}).json()
    if not listing:
        return
    subject_code = listing[0]["subject_code"]

    response = client.get(f"/results/{subject_code}")
    assert response.status_code == 200
    assert response.json()["subject_code"] == subject_code


def test_stats_returns_participants_count(client):
    response = client.get("/stats")
    assert response.status_code == 200
    assert "participants_count" in response.json()
