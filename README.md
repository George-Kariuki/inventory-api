# Inventory API (Learning Journey)

A step-by-step learning project to master backend development and DevOps fundamentals. This project evolves through 4 stages, starting with basic REST APIs and progressing to infrastructure automation and observability.

## Current Stage

**Stage 3 – Mid-Level DevOps (Focus: CI/CD Automation)**

### Learning Goals
- ✅ Build a solid REST API with Python (FastAPI)
- ✅ Understand HTTP status codes and request/response patterns
- ✅ Learn basic database operations (SQL)
- ⏳ Practice clean code principles (KISS, SOLID, YAGNI)
- ✅ Basic tests with Pytest

### Progress Checklist
- [x] Set up Poetry project
- [x] Implement FastAPI skeleton
- [x] Add first product endpoints (CRUD operations)
- [x] Database models and migrations
- [x] Error handling and validation
- [x] Basic tests with Pytest

## Project Stages Overview

1. **Stage 1**: Backend Developer (Code & Logic) - ✅ *Completed*
2. **Stage 2**: Junior DevOps (Packaging with Docker) - ✅ *Completed*
3. **Stage 3**: Mid-Level DevOps (CI/CD Automation) - *Current* ✅
4. **Stage 4**: Senior DevOps (Scale & Observability)

---

## Stage 1: Step-by-Step Implementation Guide

### Step 1: Project Setup with Poetry

**What is Poetry?**
- Manages Python dependencies (like `package.json` for Node.js)
- Creates isolated virtual environments automatically
- Locks dependency versions for reproducible builds
- Generates a `pyproject.toml` file (modern Python project config)

**Commands:**

```bash
# Install Poetry (if not already installed)
pip3 install poetry

# Navigate to project directory
cd "/Users/georgekariuki/Desktop/Inventory API"

# Initialize Poetry project (creates pyproject.toml)
poetry init --no-interaction --name inventory-api --version 0.1.0 \
  --description "A learning project for backend and DevOps fundamentals" \
  --author "Your Name <your.email@example.com>" \
  --python "^3.12" \
  --dependency fastapi \
  --dependency uvicorn \
  --dependency sqlmodel \
  --dependency python-dotenv
```

**Manual Setup Alternative:**

Create [`pyproject.toml`](pyproject.toml) manually with the following structure:

```toml
[tool.poetry]
name = "inventory-api"
version = "0.1.0"
description = "A learning project for backend and DevOps fundamentals"
authors = ["Your Name <your.email@example.com>"]
readme = "README.md"
package-mode = false  # Important: This is an app, not a library

[tool.poetry.dependencies]
python = "^3.12"
fastapi = "^0.115.0"
uvicorn = {extras = ["standard"], version = "^0.32.0"}
sqlmodel = "^0.0.24"
python-dotenv = "^1.0.0"

[tool.poetry.group.dev.dependencies]
pytest = "^8.3.0"
pytest-asyncio = "^0.24.0"
httpx = "^0.27.0"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
```

**Install Dependencies:**

```bash
poetry install
```

**Key Files:**
- [`pyproject.toml`](pyproject.toml) - Project configuration and dependencies

---

### Step 2: Create Project Structure

**Goal:** Organize code into logical folders for maintainability.

**Commands:**

```bash
# Create directory structure
mkdir -p app/models app/api

# Create __init__.py files to make them Python packages
touch app/__init__.py
touch app/models/__init__.py
touch app/api/__init__.py
```

**Project Structure:**
```
Inventory API/
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI app entry point
│   ├── database.py          # Database connection & session management
│   ├── models/
│   │   ├── __init__.py
│   │   └── product.py       # Product data models
│   └── api/
│       ├── __init__.py
│       └── products.py      # Product CRUD endpoints
├── pyproject.toml
├── .gitignore
└── README.md
```

---

### Step 3: Create FastAPI Application Skeleton

**Goal:** Set up the basic FastAPI app with CORS middleware and health check endpoints.

**File:** [`app/main.py`](app/main.py)

**What this file does:**
- Creates a FastAPI app instance with metadata
- Sets up CORS (Cross-Origin Resource Sharing) for frontend access
- Defines root and health check endpoints

**Key Concepts:**
- `from fastapi import FastAPI` - Imports the FastAPI framework
- `app = FastAPI(...)` - Creates the app instance with metadata
- `CORSMiddleware` - Allows frontend apps to call this API (we'll restrict this later)
- `@app.get("/")` - Decorator that creates a GET endpoint at the root URL
- `async def root()` - Async function (FastAPI supports async for better performance)

**Initial Code:**

See full implementation in [`app/main.py`](app/main.py)

**Test the Server:**

```bash
# Start the development server
poetry run uvicorn app.main:app --reload --port 8000

# In another terminal, test the endpoints:
curl http://localhost:8000/
curl http://localhost:8000/health
```

**Expected Response:**
```json
{
  "message": "Welcome to Inventory API",
  "status": "running",
  "version": "0.1.0"
}
```

---

### Step 4: Create Product Database Model

**Goal:** Define the Product data structure using SQLModel.

**What SQLModel does:**
- Combines Pydantic (validation) and SQLAlchemy (database)
- One class defines both the database table and the API schema
- Type-safe and auto-generates API docs

**File:** [`app/models/product.py`](app/models/product.py)

**Model Structure:**
- `ProductBase` - Shared fields (name, description, quantity, price)
- `Product` - Database table model (`table=True` creates the SQL table)
- `ProductCreate` - Schema for creating products (no id/timestamps)
- `ProductRead` - Schema for reading products (includes id/timestamps)
- `ProductUpdate` - Schema for updates (all fields optional)

**Why separate schemas?**
- **Security:** Don't expose internal fields (like `created_at`) in create requests
- **Validation:** Different rules for create vs update
- **API docs:** FastAPI auto-generates docs from these schemas

**Fields:**
- `id`: Auto-incrementing primary key
- `name`: Product name (required, 1-100 chars)
- `description`: Optional description (max 500 chars)
- `quantity`: Stock quantity (default 0, must be >= 0)
- `price`: Price per unit (must be > 0)
- `created_at` / `updated_at`: Timestamps

See full implementation in [`app/models/product.py`](app/models/product.py)

**Update [`app/models/__init__.py`](app/models/__init__.py):**

Add this import so SQLModel registers the model:

```python
from app.models.product import Product, ProductCreate, ProductRead, ProductUpdate

__all__ = ["Product", "ProductCreate", "ProductRead", "ProductUpdate"]
```

---

### Step 5: Database Configuration

**Goal:** Configure SQLModel to connect to a database.

**Note:** We'll use SQLite for Stage 1 (no setup required). We'll switch to PostgreSQL in later stages.

**File:** [`app/database.py`](app/database.py)

**Key Components:**
- `DATABASE_URL = "sqlite:///./inventory.db"` - SQLite file path (creates `inventory.db` in project root)
- `create_engine()` - Creates the database connection
- `create_db_and_tables()` - Creates all tables defined in your models
- `get_session()` - Dependency function that provides a database session for each request

See full implementation in [`app/database.py`](app/database.py)

**Update [`app/main.py`](app/main.py) to initialize database:**

Add these imports and lifespan handler:

```python
from contextlib import asynccontextmanager
from app.database import create_db_and_tables
from app.models import Product  # Import models so SQLModel registers them

@asynccontextmanager
async def lifespan(app: FastAPI):
    create_db_and_tables()
    yield

app = FastAPI(
    title="Inventory API",
    description="A learning project for backend and DevOps fundamentals",
    version="0.1.0",
    lifespan=lifespan  # Add this parameter
)
```

---

### Step 6: Create Product API Routes (CRUD)

**Goal:** Implement CRUD endpoints (Create, Read, Update, Delete).

**File:** [`app/api/products.py`](app/api/products.py)

**Endpoints:**
- `POST /products/` - Create a product
- `GET /products/` - List all products
- `GET /products/{id}` - Get one product
- `PUT /products/{id}` - Update a product
- `DELETE /products/{id}` - Delete a product

**Key Concepts:**
- `APIRouter` - Groups related endpoints (all under `/products`)
- `Depends(get_session)` - FastAPI dependency injection (provides a DB session)
- `response_model` - Tells FastAPI which schema to use for the response
- `HTTPException` - Returns proper error status codes (404, 500, etc.)
- `status.HTTP_201_CREATED` - HTTP status codes (201 = created, 204 = no content)

See full implementation in [`app/api/products.py`](app/api/products.py)

**Register the router in [`app/main.py`](app/main.py):**

Add these lines:

```python
from app.api import products

# ... existing code ...

app.include_router(products.router)
```

---

### Step 7: Create .gitignore

**Goal:** Avoid committing unnecessary files to version control.

**File:** [`.gitignore`](.gitignore)

See full contents in [`.gitignore`](.gitignore)

**Key exclusions:**
- Python cache files (`__pycache__/`, `*.pyc`)
- Virtual environments (`venv/`, `.venv/`)
- Database files (`*.db`, `inventory.db`)
- Environment variables (`.env`)
- IDE files (`.idea/`, `.vscode/`)

---

### Step 8: Automated Testing with Pytest

**Goal:** Write automated tests to verify API endpoints work correctly.

**Why Pytest?**

Pytest is the most commonly used Python testing framework. Here's why we chose it:

1. **Simplicity and Readability**
   - Tests are just functions starting with `test_`
   - Uses simple `assert` statements (no need to learn special assertion methods)
   - Clean, Pythonic syntax that's easy to read and write

2. **Automatic Test Discovery**
   - Automatically finds and runs all test files (`test_*.py`) and test functions (`test_*`)
   - No need to manually register tests or create test suites
   - Just run `pytest` and it finds everything

3. **Rich Plugin Ecosystem**
   - Thousands of plugins available (coverage, async, mocking, etc.)
   - Easy to extend functionality without modifying core code
   - Well-maintained and widely used plugins

4. **Fixtures**
   - Powerful fixture system for test setup and teardown
   - Share common test data and setup across multiple tests
   - Dependency injection for test dependencies
   - Scope control (function, class, module, session)

5. **Detailed Failure Information**
   - Shows exactly what failed and why
   - Displays variable values when assertions fail
   - Clear error messages with context
   - Verbose output options (`-v`, `-vv`)

6. **Integration with Other Tools**
   - Works seamlessly with CI/CD pipelines
   - Integrates with coverage tools (pytest-cov)
   - Compatible with IDEs (VS Code, PyCharm)
   - Can generate reports in multiple formats

**Benefits of Automated Testing:**
- Catch bugs before deployment
- Document expected behavior
- Enable safe refactoring
- Learn testing best practices
- Confidence when making changes

**Commands:**

```bash
# Create test directory structure
mkdir -p tests

# Create __init__.py to make it a Python package
touch tests/__init__.py
```

**Files Created:**
- [`tests/conftest.py`](tests/conftest.py) - Test fixtures (test database, test client)
- [`tests/test_products.py`](tests/test_products.py) - Tests for product endpoints

**Key Concepts:**

1. **Fixtures** (`@pytest.fixture`) - Reusable test setup that runs before each test
   - `test_session` - Creates a fresh test database for each test (isolated)
   - `client` - FastAPI TestClient that uses the test database

2. **Test Database** - Separate database (`test_inventory.db`) so tests don't affect real data
   - Created fresh for each test
   - Automatically cleaned up after each test

3. **TestClient** - FastAPI's test client for making HTTP requests
   - Simulates HTTP requests without running a server
   - Returns response objects just like real requests

4. **Dependency Override** - Replace real database with test database during tests
   - Uses `app.dependency_overrides` to swap dependencies
   - Ensures tests use test database, not production

**Test Coverage:**

Our test suite includes 14 tests covering:
- ✅ Create product (full and minimal data)
- ✅ List all products (empty and with data)
- ✅ Get product by ID (success and not found)
- ✅ Update product (partial and full updates)
- ✅ Delete product (success and not found)
- ✅ Validation errors (empty name, negative price/quantity)

See full test implementation in [`tests/test_products.py`](tests/test_products.py)

**Understanding [`tests/conftest.py`](tests/conftest.py):**

```python
@pytest.fixture(scope="function")
def test_session() -> Generator[Session, None, None]:
    # Creates tables before test
    SQLModel.metadata.create_all(test_engine)
    with Session(test_engine) as session:
        yield session  # Provides session to test
    # Drops tables after test (cleanup)
    SQLModel.metadata.drop_all(test_engine)
```

**Run Tests:**

```bash
# Run all tests with verbose output
poetry run pytest tests/ -v

# Run specific test file
poetry run pytest tests/test_products.py -v

# Run specific test function
poetry run pytest tests/test_products.py::test_create_product -v

# Run with coverage report (requires pytest-cov)
poetry run pytest tests/ --cov=app --cov-report=html
```

**Expected Output:**
```
============================= test session starts ==============================
tests/test_products.py::test_create_product PASSED                       [  7%]
tests/test_products.py::test_create_product_minimal PASSED               [ 14%]
tests/test_products.py::test_get_products_empty PASSED                   [ 21%]
tests/test_products.py::test_get_products PASSED                         [ 28%]
tests/test_products.py::test_get_product_by_id PASSED                    [ 35%]
tests/test_products.py::test_get_product_not_found PASSED                [ 42%]
tests/test_products.py::test_update_product PASSED                       [ 50%]
tests/test_products.py::test_update_product_all_fields PASSED            [ 57%]
tests/test_products.py::test_update_product_not_found PASSED             [ 64%]
tests/test_products.py::test_delete_product PASSED                       [ 71%]
tests/test_products.py::test_delete_product_not_found PASSED             [ 78%]
tests/test_products.py::test_create_product_validation_errors PASSED     [ 85%]
tests/test_products.py::test_create_product_negative_price PASSED          [ 92%]
tests/test_products.py::test_create_product_negative_quantity PASSED     [100%]

============================== 14 passed in 0.07s ==============================
```

**What You Learned:**
- **Pytest fixtures** - Reusable test setup with `@pytest.fixture`
- **Test isolation** - Each test uses a fresh database
- **Dependency injection** - Override real dependencies with test ones
- **Assertions** - Simple `assert` statements to verify behavior
- **Test organization** - Separate test files and fixtures

---

## Testing the API

### Option 1: Using cURL (Command Line)

**Start the server:**
```bash
poetry run uvicorn app.main:app --reload --port 8000
```

**Test Endpoints:**

```bash
# Create a product
curl -X POST http://localhost:8000/products/ \
  -H "Content-Type: application/json" \
  -d '{"name": "Laptop", "description": "Gaming laptop", "quantity": 10, "price": 999.99}'

# List all products
curl http://localhost:8000/products/ | python3 -m json.tool

# Get a specific product (replace 1 with actual product ID)
curl http://localhost:8000/products/1 | python3 -m json.tool

# Update a product
curl -X PUT http://localhost:8000/products/1 \
  -H "Content-Type: application/json" \
  -d '{"quantity": 5}' | python3 -m json.tool

# Delete a product
curl -X DELETE http://localhost:8000/products/1
```

### Option 2: Using Postman

**Quick Setup (Import Collection):**
1. Open Postman
2. Click **Import** button
3. Select the file: [`postman_collection.json`](postman_collection.json)
4. The collection will be imported with all endpoints pre-configured
5. Set the `base_url` variable to `http://localhost:8000` (or use the default)

**Manual Setup:**
1. Open Postman
2. Create a new Collection: "Inventory API"
3. Set base URL variable: `base_url = http://localhost:8000`

**Endpoints to Test:**

#### 1. Root Endpoint
- **Method:** GET
- **URL:** `{{base_url}}/`
- **Expected Status:** 200 OK

#### 2. Health Check
- **Method:** GET
- **URL:** `{{base_url}}/health`
- **Expected Status:** 200 OK
- **Response:**
  ```json
  {
    "status": "healthy"
  }
  ```

#### 3. Create Product
- **Method:** POST
- **URL:** `{{base_url}}/products/`
- **Headers:** 
  - `Content-Type: application/json`
- **Body (raw JSON):**
  ```json
  {
    "name": "Laptop",
    "description": "Gaming laptop with RTX 4090",
    "quantity": 10,
    "price": 999.99
  }
  ```
- **Expected Status:** 201 Created
- **Response:** Returns created product with `id`, `created_at`, `updated_at`

#### 4. List All Products
- **Method:** GET
- **URL:** `{{base_url}}/products/`
- **Expected Status:** 200 OK
- **Response:** Array of all products

#### 5. Get Single Product
- **Method:** GET
- **URL:** `{{base_url}}/products/1` (replace 1 with actual product ID)
- **Expected Status:** 200 OK
- **Response:** Single product object
- **Error Test:** Try `{{base_url}}/products/999` - Should return 404 Not Found

#### 6. Update Product
- **Method:** PUT
- **URL:** `{{base_url}}/products/1` (replace 1 with actual product ID)
- **Headers:** 
  - `Content-Type: application/json`
- **Body (raw JSON):**
  ```json
  {
    "quantity": 5
  }
  ```
- **Expected Status:** 200 OK
- **Response:** Updated product with new `updated_at` timestamp
- **Note:** You can update any combination of fields (name, description, quantity, price)

#### 7. Delete Product
- **Method:** DELETE
- **URL:** `{{base_url}}/products/1` (replace 1 with actual product ID)
- **Expected Status:** 204 No Content
- **Response:** Empty body
- **Error Test:** Try deleting the same product twice - Should return 404 Not Found

**Postman Tips:**
- Use the **Tests** tab to add assertions (e.g., `pm.response.to.have.status(201)`)
- Save responses as examples for documentation
- Use environment variables for different environments (dev, staging, prod)
- Import the OpenAPI schema from `http://localhost:8000/openapi.json` for auto-generated collection

### Option 3: Interactive API Documentation

FastAPI automatically generates interactive documentation:

- **Swagger UI:** http://localhost:8000/docs
- **ReDoc:** http://localhost:8000/redoc
- **OpenAPI Schema:** http://localhost:8000/openapi.json

You can test all endpoints directly from the browser!

---

## What We've Accomplished

### ✅ Project Setup
- Poetry for dependency management
- Project structure (`app/`, `models/`, `api/`)
- `.gitignore` for version control

### ✅ FastAPI Application
- Basic app with CORS middleware
- Health check endpoint
- Auto-generated API docs at `/docs`

### ✅ Database Layer
- SQLModel models (Product with validation)
- SQLite database setup
- Automatic table creation on startup

### ✅ REST API
- Full CRUD operations for products
- Proper HTTP status codes (200, 201, 204, 404)
- Error handling (404 for not found)
- Request/response validation

### ✅ Automated Testing
- Pytest test suite with 14 tests
- Test fixtures for database isolation
- Full CRUD endpoint coverage
- Validation error testing

---

## Key Concepts Learned

### HTTP Fundamentals
- **Methods:** GET, POST, PUT, DELETE
- **Status Codes:** 200 (OK), 201 (Created), 204 (No Content), 404 (Not Found)
- **REST API Design:** Resource-based URLs, proper HTTP verbs

### FastAPI
- Async/await support
- Automatic API documentation (Swagger UI)
- Type validation with Pydantic
- Dependency injection with `Depends()`

### Database
- **ORM Concepts:** Object-Relational Mapping
- **Sessions:** Context managers for proper connection handling
- **Migrations:** Automatic table creation

### Python
- Type hints
- Async/await
- Context managers
- Package structure (`__init__.py`)

### Testing
- **Pytest Framework** - Most popular Python testing tool
- **Fixtures** - Reusable test setup and teardown
- **Test Isolation** - Each test runs in isolation
- **TestClient** - FastAPI's built-in testing client

---

## Next Steps for Stage 1

- [x] ✅ Add tests with Pytest (test the API endpoints)
- [ ] Improve error handling (custom exceptions, better messages)
- [ ] Add input validation (edge cases, business rules)
- [ ] Add pagination for list endpoints
- [ ] Add filtering and search capabilities

---

## Running the Project

**Install dependencies:**
```bash
poetry install
```

**Start the server:**
```bash
poetry run uvicorn app.main:app --reload --port 8000
```

**Access the API:**
- API: http://localhost:8000
- Interactive Docs: http://localhost:8000/docs
- OpenAPI Schema: http://localhost:8000/openapi.json

---

## Troubleshooting

**Port already in use:**
```bash
# Use a different port
poetry run uvicorn app.main:app --reload --port 8001
```

**Database not created:**
- Make sure the server started successfully
- Check that `app/models/__init__.py` imports the Product model
- Verify `create_db_and_tables()` is called in the lifespan handler

**Import errors:**
- Make sure you're using `poetry run` to execute commands
- Verify all dependencies are installed: `poetry install`

**Test failures:**
- Make sure test database is created: Check for `test_inventory.db` file
- Verify fixtures are set up correctly in `tests/conftest.py`
- Run tests with `-v` flag for verbose output: `poetry run pytest tests/ -v`
- Ensure all test dependencies are installed: `poetry install`

---

## Advanced Enhancements (Optional)

Want to keep leveling up this API? The following add-ons introduce real-world concerns such as stricter validation, pagination, and flexible querying. Each subsection explains **where** to place the code, **how** to wire it up, and **when** to use it.

### 1. Input Validation & Business Rules

**Goal:** prevent bad data and enforce product rules.

**Steps**
1. Open `app/models/product.py`
   - Replace the existing imports with:
     ```python
     from datetime import datetime, timezone
     from typing import Optional
     from sqlmodel import SQLModel, Field
     ```
   - Extend `ProductBase` with extra guards:
     ```python
     class ProductBase(SQLModel):
         name: str = Field(min_length=1, max_length=100)
         description: Optional[str] = Field(default=None, max_length=500)
         quantity: int = Field(default=0, ge=0)
         price: float = Field(gt=0)

         @field_validator("name")
         @classmethod
         def validate_name(cls, value: str) -> str:
             cleaned = value.strip()
             if not cleaned:
                 raise ValueError("Name cannot be blank or whitespace")
             return cleaned

         @field_validator("price")
         @classmethod
         def validate_price(cls, value: float) -> float:
             if value > 1_000_000:
                 raise ValueError("Price cannot exceed 1,000,000")
             return round(value, 2)
     ```
     *(FastAPI 0.115+ ships with Pydantic v2, hence `field_validator`.)*
2. Open `app/api/products.py`
   - Before creating a product, ensure uniqueness:
     ```python
     existing = session.exec(
         select(Product).where(Product.name.ilike(product.name))
     ).first()
     if existing:
         raise HTTPException(
             status_code=status.HTTP_400_BAD_REQUEST,
             detail=f"Product '{product.name}' already exists"
         )
     ```

**Use Cases**
- Block duplicate names before launch
- Round prices to two decimals and enforce upper bounds
- Enforce “no empty string” rules without database triggers

---

### 2. Pagination for `/products`

**Goal:** avoid returning massive payloads as data grows.

**Steps**
1. Create `app/models/pagination.py`
   ```python
   from sqlmodel import SQLModel, Field

   class PaginationParams(SQLModel):
       page: int = Field(default=1, ge=1)
       page_size: int = Field(default=10, ge=1, le=100)

   class PaginatedResponse(SQLModel):
       items: list
       total: int
       page: int
       page_size: int
       total_pages: int

       @classmethod
       def build(cls, items, total, page, page_size):
           total_pages = (total + page_size - 1) // page_size
           return cls(
               items=items,
               total=total,
               page=page,
               page_size=page_size,
               total_pages=total_pages,
           )
   ```
2. Update `app/api/products.py`
   - Import `PaginationParams` and `PaginatedResponse`
   - Change the `GET /products/` handler to accept `pagination: PaginationParams = Depends()`
   - Compute `offset = (pagination.page - 1) * pagination.page_size`
   - Run a `select(func.count(Product.id))` for totals
   - Return `PaginatedResponse.build(...)`

**Use Cases**
- `GET /products/?page=2&page_size=20` for dashboards
- Prevent clients from downloading thousands of rows at once
- Display total counts and total pages in UI tables

---

### 3. Filtering & Search

**Goal:** let consumers query by price range, quantity, or fuzzy text.

**Steps**
1. Create `app/models/filters.py`
   ```python
   from typing import Optional
   from sqlmodel import SQLModel, Field

   class ProductFilters(SQLModel):
       name: Optional[str] = Field(default=None)
       min_price: Optional[float] = Field(default=None, ge=0)
       max_price: Optional[float] = Field(default=None, ge=0)
       min_quantity: Optional[int] = Field(default=None, ge=0)
       max_quantity: Optional[int] = Field(default=None, ge=0)
       in_stock: Optional[bool] = None
   ```
2. Update `app/api/products.py`
   - Import `ProductFilters`
   - Accept `filters: ProductFilters = Depends()` and `search: Optional[str] = Query(None)`
   - Build a list of SQLAlchemy conditions based on provided filters and `search`
   - Apply the conditions to both the `count` query and the main query before pagination

**Use Cases**
- `GET /products/?min_price=100&max_price=500`
- `GET /products/?in_stock=true&min_quantity=5`
- `GET /products/?search=laptop` (matches name or description)
- Combine with pagination: `GET /products/?search=gaming&page=1&page_size=5`

---

### Putting It All Together

Once the three enhancements are in place:
- Your `/products` endpoint supports **business-safe writes**, **paginated responses**, and **rich filters**.
- Update tests (`tests/test_products.py`) to cover the new behaviors (e.g., duplicate prevention, pagination metadata, filter combos).
- Document the new query parameters in the Postman collection or Swagger descriptions so consumers know what’s available.

Feel free to tackle these in any order—each change is isolated and can be merged independently.


---

## Stage 2: Step-by-Step Implementation Guide

### What is Docker?

Docker packages your application and all its dependencies into a **container**—a lightweight, portable unit that runs the same way on any machine. This solves the classic "it works on my machine" problem.

**Benefits:**
- **Consistency** - Runs identically on development, staging, and production
- **Isolation** - App doesn't interfere with host system or other apps
- **Portability** - Works on any machine with Docker installed
- **Simplified Deployment** - One command to run everything

**Key Concepts:**
- **Image** - A read-only template for creating containers (like a class in OOP)
- **Container** - A running instance of an image (like an object)
- **Dockerfile** - Instructions for building an image
- **Docker Compose** - Tool for running multi-container applications

---

### Step 1: Install Docker

**Before we start, you need Docker installed:**

**macOS:**
```bash
# Install Docker Desktop for Mac
# Download from: https://www.docker.com/products/docker-desktop
# Or use Homebrew:
brew install --cask docker
```

**Linux (Ubuntu/Debian):**
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add your user to docker group (logout/login required)
sudo usermod -aG docker $USER
```

**Verify Installation:**
```bash
docker --version
docker-compose --version
```

---

### Step 2: Create Dockerfile

**Goal:** Define how to build the application container.

**File:** [`Dockerfile`](Dockerfile)

**What is a Dockerfile?**
A Dockerfile is a recipe that tells Docker:
- What base image to use (Python 3.12)
- What dependencies to install
- What code to copy
- What command to run when the container starts

**Create the Dockerfile:**

```dockerfile
FROM python:3.12-slim

WORKDIR /app

RUN pip install poetry==1.8.3

COPY pyproject.toml poetry.lock* ./

RUN poetry config virtualenvs.create false && \
    poetry install --no-interaction --no-ansi --no-root --no-dev

COPY . .

RUN poetry install --no-interaction --no-ansi --no-dev

EXPOSE 8000

CMD ["poetry", "run", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**Understanding the Dockerfile:**
- `FROM python:3.12-slim` - Base image (lightweight Python 3.12)
- `WORKDIR /app` - Sets working directory inside container
- `RUN pip install poetry==1.8.3` - Installs Poetry for dependency management
- `COPY pyproject.toml poetry.lock* ./` - Copies dependency files first (Docker layer caching)
- `RUN poetry install` - Installs dependencies (without dev dependencies)
- `COPY . .` - Copies application code
- `EXPOSE 8000` - Documents that app uses port 8000
- `CMD [...]` - Default command when container starts

**Why copy `pyproject.toml` before code?**
Docker uses **layer caching**. If dependencies don't change, Docker reuses the cached layer, making builds faster.

**Why `--no-dev`?**
Production containers don't need test dependencies (pytest, etc.), making the image smaller.

See full implementation in [`Dockerfile`](Dockerfile)

---

### Step 3: Create .dockerignore

**Goal:** Exclude unnecessary files from Docker build context (faster builds, smaller images).

**File:** [`.dockerignore`](.dockerignore)

**What to exclude:**
- Python cache files (`__pycache__/`, `*.pyc`)
- Virtual environments (already in container)
- Git files (not needed in container)
- Test files (not needed in production)
- Database files (will use PostgreSQL)
- IDE files

**Why it matters:**
- Faster builds (less to copy)
- Smaller images (less data)
- Security (don't copy secrets)

**Create `.dockerignore`:**

See full contents in [`.dockerignore`](.dockerignore)

**Key exclusions:**
```
__pycache__/
*.pyc
*.db
*.sqlite
venv/
.venv
.git/
tests/
.vscode/
.idea/
```

---

### Step 4: Update Database Configuration

**Goal:** Make database URL configurable via environment variables.

**File:** [`app/database.py`](app/database.py)

**Why?**
- Local development: Use SQLite (simple, no setup)
- Docker/Production: Use PostgreSQL (more robust, scalable)

**Update the file:**

Replace the existing code with:

```python
import os
from sqlmodel import create_engine, SQLModel, Session
from typing import Generator
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./inventory.db")

if DATABASE_URL.startswith("sqlite"):
    engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
else:
    engine = create_engine(DATABASE_URL)

def create_db_and_tables():
    SQLModel.metadata.create_all(engine)

def get_session() -> Generator[Session, None, None]:
    with Session(engine) as session:
        yield session
```

**Changes Made:**
- Added `os.getenv()` to read `DATABASE_URL` from environment
- Defaults to SQLite for local development
- Supports PostgreSQL connection string for Docker
- Uses `load_dotenv()` to load `.env` file if present

See updated implementation in [`app/database.py`](app/database.py)

---

### Step 5: Add PostgreSQL Driver

**Goal:** Add PostgreSQL database driver to dependencies.

**File:** [`pyproject.toml`](pyproject.toml)

**Why `psycopg2-binary`?**
- Binary package (no compilation needed)
- Official PostgreSQL adapter for Python
- Required for SQLModel to connect to PostgreSQL

**Update `pyproject.toml`:**

Add to `[tool.poetry.dependencies]`:

```toml
psycopg2-binary = "^2.9.9"
```

**Update Lock File:**

```bash
# Update poetry.lock with new dependency
poetry lock

# Install the new dependency
poetry install
```

**Verify:**

```bash
# Check if poetry.lock exists
ls -la poetry.lock
```

---

### Step 6: Create docker-compose.yml

**Goal:** Define and run multi-container application (app + database).

**File:** [`docker-compose.yml`](docker-compose.yml)

**What is Docker Compose?**
A tool for defining and running multi-container Docker applications. One command (`docker-compose up`) starts everything.

**Our Setup:**
- **`db` service** - PostgreSQL database
- **`app` service** - FastAPI application

**Create `docker-compose.yml`:**

```yaml
version: '3.8'

services:
  db:
    image: postgres:16-alpine
    container_name: inventory_db
    environment:
      POSTGRES_USER: inventory_user
      POSTGRES_PASSWORD: inventory_password
      POSTGRES_DB: inventory_db
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U inventory_user"]
      interval: 10s
      timeout: 5s
      retries: 5

  app:
    build: .
    container_name: inventory_api
    command: poetry run uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
    volumes:
      - .:/app
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: postgresql://inventory_user:inventory_password@db:5432/inventory_db
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped

volumes:
  postgres_data:
```

**Understanding docker-compose.yml:**

**`db` service:**
- `image: postgres:16-alpine` - Use official PostgreSQL image (Alpine = smaller)
- `container_name: inventory_db` - Name of container
- `environment:` - Database credentials
- `volumes:` - Persistent data storage (survives container restarts)
- `ports:` - Expose port 5432 to host
- `healthcheck:` - Ensures database is ready before app starts

**`app` service:**
- `build: .` - Build from Dockerfile in current directory
- `command:` - Override default command (adds `--reload` for development)
- `volumes:` - Mount code for hot reload (development)
- `environment:` - Database connection URL
- `depends_on:` - Wait for database to be healthy
- `restart: unless-stopped` - Auto-restart on failure

**Key Concepts:**
- **Services** - Individual containers (app, db)
- **Volumes** - Persistent data storage (survives container restarts)
- **Networks** - Containers can communicate by service name (`db`)
- **Depends_on** - Start order (app waits for db)
- **Healthcheck** - Ensures db is ready before starting app

See full implementation in [`docker-compose.yml`](docker-compose.yml)

---

### Step 7: Build and Run with Docker

**Commands:**

```bash
# Build and start all services
docker-compose up --build

# Run in background (detached mode)
docker-compose up -d --build

# View logs
docker-compose logs -f

# View logs for specific service
docker-compose logs -f app
docker-compose logs -f db

# Stop all services
docker-compose down

# Stop and remove volumes (deletes database data)
docker-compose down -v
```

**What Happens:**
1. Docker builds the app image from Dockerfile
2. Pulls PostgreSQL image from Docker Hub
3. Creates network for containers to communicate
4. Creates volume for database persistence
5. Starts database container
6. Waits for database to be healthy (healthcheck)
7. Starts app container
8. App connects to database

**Test the API:**

```bash
# API should be available at:
curl http://localhost:8000/
curl http://localhost:8000/health
curl http://localhost:8000/products/
```

**Access Points:**
- API: http://localhost:8000
- Interactive Docs: http://localhost:8000/docs
- Database: localhost:5432 (user: `inventory_user`, password: `inventory_password`)

---

### Step 8: Docker Commands Reference

**Image Management:**
```bash
# Build image manually
docker build -t inventory-api .

# List images
docker images

# Remove image
docker rmi inventory-api
```

**Container Management:**
```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# View container logs
docker logs inventory_api

# Execute command in running container
docker exec -it inventory_api bash

# Stop container
docker stop inventory_api

# Remove container
docker rm inventory_api
```

**Docker Compose:**
```bash
# Start services
docker-compose up

# Start in background
docker-compose up -d

# Stop services
docker-compose down

# Rebuild and start
docker-compose up --build

# View logs
docker-compose logs -f app
docker-compose logs -f db

# Execute command in service
docker-compose exec app bash
docker-compose exec db psql -U inventory_user -d inventory_db
```

---

## What We've Accomplished in Stage 2

### ✅ Containerization
- Dockerfile for building app container
- .dockerignore for optimized builds
- Application runs in isolated container

### ✅ Multi-Container Setup
- Docker Compose configuration
- PostgreSQL database container
- App and database work together

### ✅ Environment Configuration
- Environment variable support
- Database URL configuration
- Development vs production setup

### ✅ Production-Ready
- Persistent data storage (volumes)
- Health checks
- Auto-restart on failure
- Proper networking

---

## Key Concepts Learned

### Docker Fundamentals
- **Images vs Containers** - Templates vs running instances
- **Layer Caching** - Faster builds by reusing layers
- **Volumes** - Persistent data storage
- **Networks** - Container communication

### Docker Compose
- **Services** - Multi-container applications
- **Dependencies** - Service startup order
- **Health Checks** - Ensure services are ready
- **Environment Variables** - Configuration management

### DevOps Practices
- **Infrastructure as Code** - Dockerfile and docker-compose.yml
- **Reproducible Environments** - Same setup everywhere
- **Isolation** - Apps don't interfere with each other
- **Portability** - Run anywhere Docker is installed

---

## Running the Project (Docker)

**Using Docker Compose (Recommended):**
```bash
# Start everything
docker-compose up --build

# Start in background
docker-compose up -d --build

# View logs
docker-compose logs -f

# Stop everything
docker-compose down
```

**Access the API:**
- API: http://localhost:8000
- Interactive Docs: http://localhost:8000/docs
- Database: localhost:5432 (user: `inventory_user`, password: `inventory_password`)

**Using Docker Only:**
```bash
# Build image
docker build -t inventory-api .

# Run container (requires external database)
docker run -p 8000:8000 \
  -e DATABASE_URL=postgresql://user:pass@host:5432/db \
  inventory-api
```

---

## Troubleshooting

**Docker not installed:**
- Install Docker Desktop (Mac/Windows) or Docker Engine (Linux)
- Verify: `docker --version`

**Port already in use:**
```bash
# Change ports in docker-compose.yml
ports:
  - "8001:8000"  # Use port 8001 on host
```

**Database connection errors:**
- Check database is healthy: `docker-compose ps`
- Verify DATABASE_URL in docker-compose.yml
- Check logs: `docker-compose logs db`

**Build fails:**
- Check Dockerfile syntax
- Verify all files exist (pyproject.toml, etc.)
- Check logs: `docker-compose build --no-cache`

**Container won't start:**
- Check logs: `docker-compose logs app`
- Verify dependencies are installed
- Check environment variables

**Data persistence issues:**
- Volumes are created automatically
- Check volume exists: `docker volume ls`
- Remove and recreate: `docker-compose down -v && docker-compose up`

---

## Next Steps for Stage 2

- [x] ✅ Create Dockerfile
- [x] ✅ Create docker-compose.yml
- [x] ✅ Configure environment variables
- [x] ✅ Switch to PostgreSQL
- [ ] Add production Dockerfile (multi-stage build)
- [ ] Add health check endpoint
- [ ] Configure logging
- [ ] Add environment-specific configs (dev/staging/prod)

---

## Quick Reference: Running Docker Containers

### Basic Commands

**Build and start containers:**
```bash
docker-compose up --build
```

**Build and start in background (detached mode):**
```bash
docker-compose up --build -d
```

**Stop containers:**
```bash
docker-compose down
```

**Stop and remove volumes (deletes database data):**
```bash
docker-compose down -v
```

**View running containers:**
```bash
docker-compose ps
# or
docker ps
```

**View logs:**
```bash
docker-compose logs -f app    # App logs
docker-compose logs -f db     # Database logs
docker-compose logs -f        # All logs
```

**Restart containers:**
```bash
docker-compose restart
```

### Common Questions

**Q: What are volumes?**
- Volumes are persistent storage that survives container restarts
- In our setup: `postgres_data` volume stores database data
- Without it, data is lost when the container stops
- With it, data persists even if you stop/restart containers
- View volumes: `docker volume ls`

**Q: What is Docker Build Cloud?**
- Docker Build Cloud is an optional Docker service for faster cloud-based builds
- Not needed here; we build locally
- Useful for CI/CD pipelines or very large builds

### Test Your API

Once containers are running, your API is available at:
- **API Root:** http://localhost:8000
- **Interactive Docs:** http://localhost:8000/docs
- **Health Check:** http://localhost:8000/health
- **Products Endpoint:** http://localhost:8000/products/

**Test with curl:**
```bash
# Create a product
curl -X POST http://localhost:8000/products/ \
  -H "Content-Type: application/json" \
  -d '{"name": "Docker Test", "price": 99.99, "quantity": 10}'

# List products
curl http://localhost:8000/products/
```

**View in Docker Desktop:**
- Open Docker Desktop application
- Go to "Containers" tab
- You'll see both `inventory_api` and `inventory_db` running
- Click on a container to view logs, stats, and more

---

## Advanced Enhancements (Optional) for Stage 2

These are optional improvements you can implement later for production-ready deployments.

### 1. Production Dockerfile (Multi-Stage Build)

**What it does:** Uses multiple build stages to create a smaller, optimized production image.

**How it would look:**

Create `Dockerfile.prod`:

```dockerfile
# Stage 1: Builder stage
FROM python:3.12-slim as builder

WORKDIR /app

# Install Poetry
RUN pip install poetry==1.8.3

# Copy dependency files
COPY pyproject.toml poetry.lock* ./

# Install dependencies (including dev for building)
RUN poetry config virtualenvs.create false && \
    poetry install --no-interaction --no-ansi --no-root

# Copy application code
COPY . .

# Install application
RUN poetry install --no-interaction --no-ansi

# Stage 2: Production stage
FROM python:3.12-slim

WORKDIR /app

# Install only runtime dependencies (no Poetry needed)
RUN pip install --no-cache-dir poetry==1.8.3

# Copy only what we need from builder
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /app /app

# Create non-root user for security
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

# Production command (no reload)
CMD ["poetry", "run", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**Benefits:**
- Smaller final image (no build tools)
- Better security (non-root user)
- Faster production builds (cached layers)

---

### 2. Health Check Endpoint

**What it does:** Endpoint that reports app health (database connectivity, etc.)

**How it would look:**

**In `app/main.py`:**

```python
from fastapi import FastAPI, Depends
from sqlmodel import Session, text
from app.database import get_session

@app.get("/health")
async def health_check(session: Session = Depends(get_session)):
    try:
        # Check database connectivity
        session.exec(text("SELECT 1"))
        db_status = "healthy"
    except Exception:
        db_status = "unhealthy"
    
    return {
        "status": "healthy" if db_status == "healthy" else "degraded",
        "database": db_status,
        "version": "0.1.0"
    }
```

**In `docker-compose.yml`:**

```yaml
app:
  # ... existing config ...
  healthcheck:
    test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
    interval: 30s
    timeout: 10s
    retries: 3
    start_period: 40s
```

**Benefits:**
- Docker can restart unhealthy containers
- Monitoring tools can check app status
- Load balancers can route traffic away from unhealthy instances

---

### 3. Configure Logging

**What it does:** Structured logging with different levels for dev/prod.

**How it would look:**

**Create `app/config.py`:**

```python
import os
import logging
from logging.handlers import RotatingFileHandler

def setup_logging():
    log_level = os.getenv("LOG_LEVEL", "INFO")
    log_format = os.getenv("LOG_FORMAT", "json")  # json or text
    
    # Configure root logger
    logging.basicConfig(
        level=getattr(logging, log_level),
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    
    # File handler for production
    if os.getenv("ENVIRONMENT") == "production":
        file_handler = RotatingFileHandler(
            'app.log',
            maxBytes=10485760,  # 10MB
            backupCount=5
        )
        file_handler.setLevel(logging.INFO)
        logging.getLogger().addHandler(file_handler)
```

**In `app/main.py`:**

```python
import logging
from app.config import setup_logging

setup_logging()
logger = logging.getLogger(__name__)

@app.get("/")
async def root():
    logger.info("Root endpoint accessed")
    return {"message": "Welcome to Inventory API"}

@app.post("/products/")
async def create_product(...):
    logger.info(f"Creating product: {product.name}")
    # ... create logic ...
    logger.info(f"Product created with ID: {db_product.id}")
```

**In `docker-compose.yml`:**

```yaml
app:
  environment:
    LOG_LEVEL: ${LOG_LEVEL:-INFO}
    LOG_FORMAT: ${LOG_FORMAT:-text}
    ENVIRONMENT: ${ENVIRONMENT:-development}
```

**Benefits:**
- Better debugging
- Production monitoring
- Structured logs for analysis

---

### 4. Environment-Specific Configs

**What it does:** Different settings for dev, staging, and production.

**How it would look:**

**Create `app/config.py`:**

```python
import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # App settings
    app_name: str = "Inventory API"
    environment: str = os.getenv("ENVIRONMENT", "development")
    debug: bool = os.getenv("DEBUG", "False").lower() == "true"
    
    # Database
    database_url: str = os.getenv("DATABASE_URL", "sqlite:///./inventory.db")
    
    # API settings
    api_host: str = os.getenv("API_HOST", "0.0.0.0")
    api_port: int = int(os.getenv("API_PORT", "8000"))
    
    # CORS
    cors_origins: list = os.getenv("CORS_ORIGINS", "*").split(",")
    
    # Security
    secret_key: str = os.getenv("SECRET_KEY", "dev-secret-key-change-in-production")
    
    class Config:
        env_file = ".env"
        case_sensitive = False

settings = Settings()
```

**Create `.env.development`:**

```env
ENVIRONMENT=development
DEBUG=true
DATABASE_URL=sqlite:///./inventory.db
LOG_LEVEL=DEBUG
CORS_ORIGINS=*
```

**Create `.env.production`:**

```env
ENVIRONMENT=production
DEBUG=false
DATABASE_URL=postgresql://user:pass@db:5432/inventory_db
LOG_LEVEL=WARNING
CORS_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
SECRET_KEY=your-super-secret-key-here
```

**Create `docker-compose.dev.yml`:**

```yaml
version: '3.8'

services:
  app:
    build: .
    environment:
      ENVIRONMENT: development
      DEBUG: "true"
      DATABASE_URL: postgresql://inventory_user:inventory_password@db:5432/inventory_db
    volumes:
      - .:/app  # Hot reload
    command: poetry run uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

**Create `docker-compose.prod.yml`:**

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.prod  # Multi-stage Dockerfile
    environment:
      ENVIRONMENT: production
      DEBUG: "false"
      DATABASE_URL: postgresql://inventory_user:inventory_password@db:5432/inventory_db
      LOG_LEVEL: WARNING
    # No volume mount (code is in image)
    command: poetry run uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4
    restart: always
```

**Usage:**

```bash
# Development
docker-compose -f docker-compose.yml -f docker-compose.dev.yml up

# Production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

**In `app/main.py`:**

```python
from app.config import settings

app = FastAPI(
    title=settings.app_name,
    debug=settings.debug,
    version="0.1.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

**Benefits:**
- Different configs per environment
- Security (no debug in production)
- Easy switching between environments

---

### Summary

These advanced enhancements provide:
- **Multi-stage Dockerfile:** Smaller, more secure production image
- **Health check:** Endpoint + Docker healthcheck for monitoring
- **Logging:** Structured logs with file rotation
- **Environment configs:** Separate settings for dev/staging/prod

These are common production practices that improve security, monitoring, and maintainability.
---

## Stage 3: Step-by-Step Implementation Guide

### What is CI/CD?

CI/CD (Continuous Integration / Continuous Deployment or Delivery) automates quality checks every time code changes land in the repository.

- **Continuous Integration (CI):** automatically tests and builds code whenever you push changes.
- **Continuous Deployment/Delivery (CD):** automatically deploys or prepares artefacts once CI succeeds (we stop at automated tests/builds for now).

**Benefits**
- Catch bugs early and keep `main` healthy.
- Automate repetitive steps (tests, builds, packaging).
- Provide visibility via GitHub Actions logs.
- Enable faster, safer releases.

**What we built**
- Git repository (locally and on GitHub).
- GitHub Actions workflow triggered on every push/PR.
- Automated steps: checkout → install deps → run tests → build Docker image.
- Workflow status visible in the GitHub Actions tab.

---

### Step 1: Initialize Git Repository

CI/CD needs version control. If you haven’t already:

```bash
# Initialize git repo (run in project root)
git init

# Inspect current status
git status
```

This creates `.git/`, enabling GitHub Actions.

---

### Step 2: Create GitHub Actions Workflow

GitHub Actions reads YAML files under `.github/workflows/`.

**File:** [`.github/workflows/ci.yml`](.github/workflows/ci.yml)

```yaml
name: CI

on:
  push:
    branches: [ main, master, develop ]
  pull_request:
    branches: [ main, master, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - uses: snok/install-poetry@v1
        with:
          version: 1.8.3
          virtualenvs-create: true
          virtualenvs-in-project: true
      - uses: actions/cache@v4
        with:
          path: .venv
          key: venv-${{ runner.os }}-3.12-${{ hashFiles('**/poetry.lock') }}
      - run: poetry install --no-interaction --no-ansi
      - run: poetry run pytest tests/ -v
      - run: poetry run python -m py_compile app/**/*.py || true

  build:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/build-push-action@v5
        with:
          context: .
          push: false
          tags: inventory-api:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

**Workflow overview**
- `test` job: checkout → Python 3.12 → install Poetry → cache deps → install → run tests → syntax check.
- `build` job: runs only if tests succeed (`needs: test`), builds Docker image with cache support.

---

### Step 3: Update `.gitignore`

Track `poetry.lock` for reproducible builds:

```diff
- poetry.lock
+# poetry.lock - Keep this for reproducible builds
```

---

### Step 4: Commit and Push to GitHub

Create a GitHub repository (https://github.com/new):
1. Name: `inventory-api` (or your preference)
2. Description: “A learning project for backend and DevOps fundamentals”
3. Public or Private
4. **Do not** initialize with README/.gitignore (we already have them)

Then connect the local repo to GitHub:

```bash
# Stage and commit
 git add .
 git commit -m "Initial commit: FastAPI Inventory API with Docker and CI/CD"

# Point to your GitHub repo (replace USERNAME)
 git remote add origin https://github.com/YOUR_USERNAME/inventory-api.git

# Push
 git branch -M main
 git push -u origin main
```

---

### Step 5: Watch CI/CD in Action

After pushing:
1. Open the GitHub repository page
2. Click the **Actions** tab
3. Workflow runs automatically (yellow dot = running, green check = success)
4. Click the job to view live logs (tests, installs, builds)

**Testing the workflow:**

```bash
# Make a change (e.g., README)
git add README.md
git commit -m "Test CI/CD"
git push
```

GitHub Actions automatically reruns. Use the Actions tab to view status and logs.

---

### Quick Reference: CI/CD Commands

```bash
# Check git status
git status

# Stage + commit changes
git add .
git commit -m "Message"

# Push (triggers CI)
git push
```

**View workflow runs:** GitHub → repository → Actions tab → select run.  
**Re-run failed jobs:** open failed run → “Re-run jobs”.

---

### What We’ve Accomplished in Stage 3

#### ✅ CI/CD Pipeline
- Git repository initialized and pushed to GitHub
- GitHub Actions workflow configured (`.github/workflows/ci.yml`)
- Automated testing on every push/PR
- Docker builds triggered automatically

#### ✅ Quality Gates
- Tests must pass before Docker build runs
- Workflow logs stored in GitHub for auditability
- Deterministic dependency management (lock file tracked)

#### ✅ Developer Experience
- Single push triggers full pipeline
- Caching speeds up repeat runs
- Failure notifications via GitHub UI/emails

---

### Key Concepts Learned (Stage 3)

- **Git & GitHub Basics**: init, add, commit, remote, push.
- **GitHub Actions**: workflows, jobs, steps, caching.
- **CI Pipelines**: automated testing gating builds.
- **Docker Build Automation**: build job ensures image integrity.
- **Observability**: checking logs/results in Actions tab.

---

### Troubleshooting CI/CD

**Workflow not running:** ensure repo is on GitHub, workflow file committed to `main`, and branch filters match.

**Workflow failed:** open Actions tab → click failed run → read logs → fix locally → push new commit. Use “Re-run jobs” after fixes if needed.

**Cache issues:** update cache key (e.g., change version string) or clear cache via GitHub Actions settings.

---

### Next Steps for Stage 3

- [x] ✅ Initialize git repository
- [x] ✅ Create GitHub Actions workflow
- [x] ✅ Track `poetry.lock` for reproducibility
- [x] ✅ Push repository to GitHub and verify Actions
- [ ] Add linting/formatting jobs (ruff, black, mypy)
- [ ] Publish Docker image to a registry (Docker Hub/GitHub Packages)
- [ ] Add deployment step (Heroku, Render, Fly.io, etc.)
- [ ] Add status badges to README (build/test status)

