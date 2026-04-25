from pydantic import BaseModel, Field

class SignupRequest(BaseModel):
    name: str = Field(min_length=1)
    phone: str = Field(min_length=1)
    password: str = Field(min_length=6, max_length=72)

class LoginRequest(BaseModel):
    phone: str = Field(min_length=1)
    password: str = Field(min_length=6, max_length=72)

class ProfileResponse(BaseModel):
    name: str
    phone: str
    language: str

class ProfileUpdateRequest(BaseModel):
    name: str = Field(min_length=1)
    language: str = Field(min_length=2, max_length=5)

class ChangePasswordRequest(BaseModel):
    current_password: str = Field(min_length=6, max_length=72)
    new_password: str = Field(min_length=6, max_length=72)


from pydantic import Field

class CropRecommendationRequest(BaseModel):
    phone: str
    N: float = Field(..., ge=0, le=200)
    P: float = Field(..., ge=0, le=200)
    K: float = Field(..., ge=0, le=200)
    temperature: float = Field(..., ge=-50, le=60)
    humidity: float = Field(..., ge=0, le=100)
    ph: float = Field(..., ge=0, le=14)
    rainfall: float = Field(..., ge=0, le=500)