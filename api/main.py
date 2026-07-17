"""
ARC Lesion Segmentation — read-only API over segmentation results.

Endpoints:
    GET /health              -> service liveness check
    GET /results             -> paginated list of participants
    GET /results/{subject}   -> metrics for a single participant
    GET /stats                -> aggregate statistics across all participants

The API connects to PostgreSQL with the read-only `qa_readonly` role
(see db/schema.sql) — it can never mutate the underlying dataset.
"""
from typing import List

from fastapi import FastAPI, HTTPException, Query
from fastapi.responses import JSONResponse

from . import db
from .schemas import HealthResponse, ParticipantResult, StatsResponse

app = FastAPI(
    title="ARC Lesion Segmentation API",
    description="Read-only access to automatic brain lesion segmentation results.",
    version="1.0.0",
)


@app.get("/health", response_model=HealthResponse)
def health() -> HealthResponse:
    return HealthResponse(status="ok")


@app.get("/results", response_model=List[ParticipantResult])
def list_results(
    limit: int = Query(default=50, ge=1, le=500),
    offset: int = Query(default=0, ge=0),
) -> List[ParticipantResult]:
    rows = db.fetch_participants(limit=limit, offset=offset)
    return [ParticipantResult(**row) for row in rows]


@app.get("/results/{subject_code}", response_model=ParticipantResult)
def get_result(subject_code: str) -> ParticipantResult:
    row = db.fetch_participant(subject_code)
    if row is None:
        raise HTTPException(status_code=404, detail=f"Subject '{subject_code}' not found")
    return ParticipantResult(**row)


@app.get("/stats", response_model=StatsResponse)
def stats() -> StatsResponse:
    row = db.fetch_stats()
    return StatsResponse(**row)


@app.exception_handler(Exception)
def unhandled_exception_handler(_request, exc: Exception) -> JSONResponse:  # noqa: ANN001
    return JSONResponse(status_code=500, content={"detail": f"Internal error: {exc}"})
