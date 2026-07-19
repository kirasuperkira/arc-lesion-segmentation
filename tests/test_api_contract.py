def test_health_response_matches_schema(client):
    schema = client.get("/openapi.json").json()
    response = client.get("/health")
    assert response.status_code == 200
    body = response.json()
    assert set(body.keys()) == {"status"}
    assert isinstance(body["status"], str)
    assert "/health" in schema["paths"]

def test_results_item_matches_schema_field_types(client):
    response = client.get("/results", params={"limit": 1})
    results = response.json()
    if not results:
        return
    item = results[0]
    assert isinstance(item["subject_code"], str)
    if item["dice_score"] is not None:
        assert isinstance(item["dice_score"], (int, float))
    if item["lesion_volume_gt"] is not None:
        assert isinstance(item["lesion_volume_gt"], int)
    if item["lesion_volume_auto"] is not None:
        assert isinstance(item["lesion_volume_auto"], int)

def test_stats_response_matches_schema_field_types(client):
    response = client.get("/stats")
    body = response.json()
    assert isinstance(body["participants_count"], int)
    for field in ("avg_dice", "min_dice", "max_dice"):
        assert field in body