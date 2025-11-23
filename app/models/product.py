from datetime import datetime, timezone
from typing import Optional
from sqlmodel import SQLModel, Field

class ProductBase(SQLModel):
    name: str = Field(min_length=1, max_length=100)
    description: Optional[str] = Field(default=None, max_length=500)
    quantity: int = Field(default=0, ge=0)
    price: float = Field(gt=0)

class Product(ProductBase, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

class ProductCreate(ProductBase):
    pass

class ProductRead(ProductBase):
    id: int
    created_at: datetime
    updated_at: datetime

class ProductUpdate(SQLModel):
    name: Optional[str] = Field(default=None, min_length=1, max_length=100)
    description: Optional[str] = Field(default=None, max_length=500)
    quantity: Optional[int] = Field(default=None, ge=0)
    price: Optional[float] = Field(default=None, gt=0)

