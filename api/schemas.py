from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class HealthResponse(BaseModel):
    status: str


class ParticipantResult(BaseModel):
    subject_code: str
    dice_score: Optional[float] = None
    lesion_volume_gt: Optional[int] = None
    lesion_volume_auto: Optional[int] = None
    processed_at: Optional[datetime] = None


class StatsResponse(BaseModel):
    participants_count: int
    avg_dice: Optional[float] = None
    min_dice: Optional[float] = None
    max_dice: Optional[float] = None
