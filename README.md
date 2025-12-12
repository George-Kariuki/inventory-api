# Inventory API (Learning Journey)

A step-by-step learning project to master backend development and DevOps fundamentals. This project evolves through 4 stages, starting with basic REST APIs and progressing to infrastructure automation and observability.

## Current Stage

**Stage 4 – Senior DevOps (Focus: Scale & Observability)**

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
3. **Stage 3**: Mid-Level DevOps (CI/CD Automation) - ✅ *Completed*
4. **Stage 4**: Senior DevOps (Scale & Observability) - *Current* ✅

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
- Complete CI/CD pipeline: linting → testing → building → Docker Hub publishing → Heroku deployment.
- Code quality tools: Ruff (linter), Black (formatter), MyPy (type checker).
- Automated Docker image publishing to Docker Hub.
- Automatic deployment to Heroku (on main branch).
- Workflow status visible in the GitHub Actions tab.
- Live API accessible on the internet!

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

### What We've Accomplished in Stage 3

#### ✅ CI/CD Pipeline
- Git repository initialized and pushed to GitHub
- GitHub Actions workflow configured (`.github/workflows/ci.yml`)
- Automated testing on every push/PR
- Docker builds triggered automatically
- **Docker images published to Docker Hub** (tagged with latest + commit SHA)
- **Automatic deployment to Heroku** (on main branch pushes)

#### ✅ Code Quality & Linting
- **Ruff linter** - Catches errors, unused imports, style issues
- **Black formatter** - Enforces consistent code style automatically
- **MyPy type checker** - Verifies type hints are correct
- All code auto-formatted and linted
- Linting runs before tests (fails fast on code quality issues)

#### ✅ Quality Gates
- Linting must pass before tests run
- Tests must pass before Docker build runs
- Build must succeed before deployment
- Workflow logs stored in GitHub for auditability
- Deterministic dependency management (lock file tracked)

#### ✅ Deployment Automation
- **Heroku Container Registry** - Docker-based deployment
- **Automatic releases** - Code goes live in ~5-10 minutes
- **Environment configuration** - Heroku PostgreSQL automatically configured
- **Live API** - Accessible at `https://YOUR_APP_NAME.herokuapp.com`

#### ✅ Developer Experience
- Single push triggers full pipeline (lint → test → build → deploy)
- Caching speeds up repeat runs
- Failure notifications via GitHub UI/emails
- Complete setup guide for easy onboarding
- Local testing commands for all tools

---

### Key Concepts Learned (Stage 3)

- **Git & GitHub Basics**: init, add, commit, remote, push.
- **GitHub Actions**: workflows, jobs, steps, caching, secrets.
- **CI/CD Pipelines**: automated linting → testing → building → deploying.
- **Code Quality Tools**: Ruff (linter), Black (formatter), MyPy (type checker).
- **Docker Registries**: storing and sharing Docker images (Docker Hub).
- **Container Deployment**: deploying Docker containers to cloud platforms (Heroku).
- **Infrastructure as Code**: defining deployment in YAML files.
- **Observability**: checking logs/results in Actions tab and Heroku dashboard.

---

### Troubleshooting CI/CD

**Workflow not running:** ensure repo is on GitHub, workflow file committed to `main`, and branch filters match.

**Workflow failed:** open Actions tab → click failed run → read logs → fix locally → push new commit. Use “Re-run jobs” after fixes if needed.

**Cache issues:** update cache key (e.g., change version string) or clear cache via GitHub Actions settings.

---

### Step 6: Add Linting and Formatting Tools

**Goal:** Automatically check code quality and enforce consistent style.

**Why linting/formatting?**
- **Catch bugs early** - Find errors before they reach production
- **Consistent code style** - All code looks the same (easier to read)
- **Learn best practices** - Tools teach you Python conventions automatically
- **Faster code reviews** - Less time discussing style, more time on logic

**Tools we added:**
- **Ruff** - Fast Python linter (catches errors, unused imports, style issues)
- **Black** - Code formatter (automatically formats code to consistent style)
- **MyPy** - Type checker (verifies type hints are correct)

**File:** [`pyproject.toml`](pyproject.toml)

**Added to dev dependencies:**
```toml
[tool.poetry.group.dev.dependencies]
ruff = "^0.6.0"
black = "^24.10.0"
mypy = "^1.11.0"
```

**Configuration added:**
```toml
[tool.black]
line-length = 100
target-version = ['py312']

[tool.ruff]
line-length = 100
target-version = "py312"

[tool.ruff.lint]
select = ["E", "W", "F", "I", "B", "C4", "UP"]
ignore = ["E501", "B008"]

[tool.mypy]
python_version = "3.12"
warn_return_any = true
ignore_missing_imports = true
```

**Updated CI workflow:** [`.github/workflows/ci.yml`](.github/workflows/ci.yml)

Added a new `lint` job that runs before tests:
```yaml
lint:
  runs-on: ubuntu-latest
  steps:
    - name: Run Ruff (linter)
      run: poetry run ruff check app/ tests/
    - name: Check Black formatting
      run: poetry run black --check app/ tests/
    - name: Run MyPy (type checker)
      run: poetry run mypy app/ || true
```

**Local commands:**
```bash
# Check for linting issues
poetry run ruff check app/

# Auto-fix linting issues
poetry run ruff check --fix app/

# Check code formatting
poetry run black --check app/

# Format code automatically
poetry run black app/

# Type check
poetry run mypy app/
```

**What happens:**
- Every push runs linting first
- If code doesn't pass, workflow fails
- Forces you to write clean, consistent code

---

### Step 7: Publish Docker Image to Docker Hub

**Goal:** Store Docker images in a registry for easy sharing and deployment.

**Why Docker Hub?**
- **Share images** - Anyone can pull and run your app
- **Version control** - Tag images with versions (v1.0.0, latest)
- **Deployment** - Production servers can pull from registry
- **Backup** - Images stored in the cloud

**Updated CI workflow:** [`.github/workflows/ci.yml`](.github/workflows/ci.yml)

**Added to build job:**
```yaml
build:
  steps:
    - name: Login to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
    
    - name: Build and push Docker image
      uses: docker/build-push-action@v5
      with:
        push: true
        tags: |
          ${{ secrets.DOCKER_USERNAME }}/inventory-api:latest
          ${{ secrets.DOCKER_USERNAME }}/inventory-api:${{ github.sha }}
```

**Image tagging:**
- `latest` - Always points to the latest main branch build
- `sha-abc123` - Specific commit (for rollback if needed)
- `main-abc123` - Branch name + commit (for feature branches)

**What happens:**
- After tests pass, Docker image is built
- Image is pushed to Docker Hub automatically
- Anyone can pull: `docker pull YOUR_USERNAME/inventory-api:latest`

---

### Step 8: Deploy to Heroku

**Goal:** Automatically deploy your app to the cloud on every push to main.

**Why Heroku?**
- **Free tier** - Great for learning and small projects
- **Easy deployment** - Just push code, Heroku handles the rest
- **Managed services** - Database, logging, monitoring included
- **Real URL** - Your API is live on the internet!

**Files created:**
- [`heroku.yml`](heroku.yml) - Heroku Docker configuration
- [`SETUP_GUIDE.md`](SETUP_GUIDE.md) - Complete setup instructions

**Updated CI workflow:** [`.github/workflows/ci.yml`](.github/workflows/ci.yml)

**Added deploy job:**
```yaml
deploy:
  runs-on: ubuntu-latest
  needs: build
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  
  steps:
    - name: Set Heroku stack to container
      run: heroku stack:set container -a ${{ secrets.HEROKU_APP_NAME }}
    
    - name: Build and push to Heroku
      run: |
        docker build -t registry.heroku.com/${{ secrets.HEROKU_APP_NAME }}/web .
        docker push registry.heroku.com/${{ secrets.HEROKU_APP_NAME }}/web
    
    - name: Release on Heroku
      run: heroku container:release web -a ${{ secrets.HEROKU_APP_NAME }}
```

**What happens:**
- Only runs on `main` branch pushes
- Sets Heroku to use container stack
- Builds Docker image for Heroku
- Pushes to Heroku Container Registry
- Releases to production automatically

**Your live API:**
- Main URL: `https://YOUR_APP_NAME.herokuapp.com`
- Interactive docs: `https://YOUR_APP_NAME.herokuapp.com/docs`
- Health check: `https://YOUR_APP_NAME.herokuapp.com/health`

---

### Step 9: Setup Guide and Configuration

**Goal:** Document the complete setup process for easy reference.

**File created:** [`SETUP_GUIDE.md`](SETUP_GUIDE.md)

**Includes:**
- Step-by-step account creation (Docker Hub, Heroku)
- GitHub secrets configuration
- Heroku PostgreSQL setup
- Troubleshooting guide
- Local testing commands

**Required GitHub Secrets:**
1. `DOCKER_USERNAME` - Your Docker Hub username
2. `DOCKER_PASSWORD` - Docker Hub access token
3. `HEROKU_EMAIL` - Heroku account email
4. `HEROKU_API_KEY` - Heroku API key
5. `HEROKU_APP_NAME` - Your Heroku app name

**Setup steps:**
1. Create Docker Hub account → Get access token
2. Create Heroku account → Create app → Get API key
3. Add PostgreSQL addon to Heroku app
4. Add all secrets to GitHub repository
5. Push code → Watch deployment!

See [`SETUP_GUIDE.md`](SETUP_GUIDE.md) for detailed instructions.

---

### What Happens on Every Push

**Complete CI/CD Pipeline:**

1. **Linting Job** (runs first)
   - Ruff checks code quality
   - Black verifies formatting
   - MyPy checks type hints
   - ✅ Pass → Continue, ❌ Fail → Stop

2. **Test Job** (runs after linting)
   - Installs dependencies
   - Runs all pytest tests
   - ✅ Pass → Continue, ❌ Fail → Stop

3. **Build Job** (runs after tests)
   - Builds Docker image
   - Pushes to Docker Hub
   - Tags with latest + commit SHA

4. **Deploy Job** (only on main branch)
   - Sets Heroku stack to container
   - Builds image for Heroku
   - Pushes to Heroku Container Registry
   - Releases to production
   - 🎉 Your API is live!

**Total time:** ~5-10 minutes from push to live deployment

---

### Files Created/Modified

**New files:**
- [`heroku.yml`](heroku.yml) - Heroku Docker configuration

**Modified files:**
- [`pyproject.toml`](pyproject.toml) - Added linting tools and configuration
- [`.github/workflows/ci.yml`](.github/workflows/ci.yml) - Added linting, Docker Hub, and Heroku deployment
- [`Dockerfile`](Dockerfile) - Added system dependencies for PostgreSQL
- All code files - Auto-formatted with black and ruff

---

### Next Steps for Stage 3

- [x] ✅ Initialize git repository
- [x] ✅ Create GitHub Actions workflow
- [x] ✅ Track `poetry.lock` for reproducibility
- [x] ✅ Push repository to GitHub and verify Actions
- [x] ✅ Add linting/formatting jobs (ruff, black, mypy)
- [x] ✅ Publish Docker image to a registry (Docker Hub)
- [x] ✅ Add deployment step (Heroku)
- [ ] Add status badges to README (build/test status)
- [ ] Add deployment notifications (Slack, email)

---

## Stage 3: Setup Guide - Accounts and Secrets Configuration

This guide will walk you through creating the necessary accounts and configuring secrets for CI/CD.

### Step 1: Create Docker Hub Account

**Why:** To store and share Docker images

**Steps:**
1. Go to https://hub.docker.com/signup
2. Create a free account (choose a username - this will be your Docker Hub username)
3. Verify your email address
4. **Note your username** - you'll need it for secrets

**What you'll need:**
- Docker Hub Username (e.g., `georgekariuki`)
- Docker Hub Password (or Access Token - recommended)

**Create Access Token (Recommended):**
1. Go to https://hub.docker.com/settings/security
2. Click "New Access Token"
3. Name it: `github-actions`
4. Copy the token (you won't see it again!)
5. Use this token as your `DOCKER_PASSWORD` secret

---

### Step 2: Create Heroku Account

**Why:** To deploy your application to the cloud

**Steps:**
1. Go to https://signup.heroku.com/
2. Create a free account
3. Verify your email address
4. **Note your email** - you'll need it for secrets

**Install Heroku CLI (Optional but helpful):**
```bash
# macOS
brew tap heroku/brew && brew install heroku

# Or download from: https://devcenter.heroku.com/articles/heroku-cli
```

**Login to Heroku:**
```bash
heroku login
```

**Create a Heroku App:**
```bash
# Create app (choose a unique name)
heroku create inventory-api-yourname

# Or create via web: https://dashboard.heroku.com/new-app
```

**Get Heroku API Key:**
1. Go to https://dashboard.heroku.com/account
2. Scroll to "API Key"
3. Click "Reveal" and copy it
4. This is your `HEROKU_API_KEY` secret

**What you'll need:**
- Heroku Email (the email you signed up with)
- Heroku API Key (from account settings)
- Heroku App Name (e.g., `inventory-api-yourname`)

---

### Step 3: Configure GitHub Secrets

**Why:** GitHub Actions needs credentials to push to Docker Hub and deploy to Heroku

**Steps:**
1. Go to your GitHub repository: https://github.com/George-Kariuki/inventory-api
2. Click **Settings** (top menu)
3. Click **Secrets and variables** → **Actions** (left sidebar)
4. Click **New repository secret** for each secret below:

#### Required Secrets:

**Docker Hub Secrets:**
- **Name:** `DOCKER_USERNAME`
  - **Value:** Your Docker Hub username (e.g., `georgekariuki`)

- **Name:** `DOCKER_PASSWORD`
  - **Value:** Your Docker Hub password OR access token (recommended)

**Heroku Secrets:**
- **Name:** `HEROKU_EMAIL`
  - **Value:** Your Heroku account email

- **Name:** `HEROKU_API_KEY`
  - **Value:** Your Heroku API key (from https://dashboard.heroku.com/account)

- **Name:** `HEROKU_APP_NAME`
  - **Value:** Your Heroku app name (e.g., `inventory-api-yourname`)

**Important:** 
- Secrets are encrypted and only visible to GitHub Actions
- Never commit secrets to your code!
- If you change a secret, update it in GitHub Settings

---

### Step 4: Configure Heroku Environment Variables

**Why:** Your app needs database connection and other configs on Heroku

**Steps:**
1. Go to https://dashboard.heroku.com/apps/YOUR_APP_NAME/settings
2. Click **Reveal Config Vars**
3. Add these variables:

**Required:**
- **Key:** `DATABASE_URL`
  - **Value:** Will be auto-created when you add PostgreSQL addon (see below)

**Optional (for production):**
- **Key:** `ENVIRONMENT`
  - **Value:** `production`

- **Key:** `LOG_LEVEL`
  - **Value:** `INFO`

---

### Step 5: Add PostgreSQL to Heroku

**Why:** Your app needs a database

**Steps:**
1. Go to https://dashboard.heroku.com/apps/YOUR_APP_NAME/resources
2. Search for "Heroku Postgres"
3. Click "Add" (free tier: "Hobby Dev")
4. The `DATABASE_URL` will be automatically set!

**Or via CLI:**
```bash
heroku addons:create heroku-postgresql:hobby-dev
```

---

### Step 6: Test the Setup

**After configuring all secrets:**

1. **Push your code:**
   ```bash
   git add .
   git commit -m "Add CI/CD with linting, Docker Hub, and Heroku"
   git push
   ```

2. **Watch GitHub Actions:**
   - Go to https://github.com/George-Kariuki/inventory-api/actions
   - Click on the running workflow
   - Watch it:
     - ✅ Run linting (ruff, black, mypy)
     - ✅ Run tests
     - ✅ Build Docker image
     - ✅ Push to Docker Hub
     - ✅ Deploy to Heroku

3. **Check your app:**
   - Go to https://YOUR_APP_NAME.herokuapp.com
   - Test endpoints: https://YOUR_APP_NAME.herokuapp.com/docs

---

### Troubleshooting (Stage 3 Setup)

**Docker Hub Push Fails:**
- Check `DOCKER_USERNAME` and `DOCKER_PASSWORD` secrets are correct
- Verify Docker Hub account is active
- Try using an access token instead of password

**Heroku Deployment Fails:**
- Check all Heroku secrets are set correctly
- Verify Heroku app name matches `HEROKU_APP_NAME` secret
- Check Heroku logs: `heroku logs --tail -a YOUR_APP_NAME`

**Linting Fails:**
- Run locally: `poetry run ruff check app/`
- Auto-fix: `poetry run ruff check --fix app/`
- Format: `poetry run black app/`

---

### Quick Reference (Stage 3)

**Local Commands:**
```bash
# Lint code
poetry run ruff check app/

# Auto-fix linting issues
poetry run ruff check --fix app/

# Format code
poetry run black app/

# Type check
poetry run mypy app/

# Run all checks
poetry run ruff check app/ && poetry run black --check app/ && poetry run mypy app/
```

**Heroku Commands:**
```bash
# View logs
heroku logs --tail -a YOUR_APP_NAME

# Open app
heroku open -a YOUR_APP_NAME

# Check app status
heroku ps -a YOUR_APP_NAME
```

---

## Stage 4: Senior DevOps (Scale & Observability) - Complete Guide

### What is Infrastructure as Code (IaC)?

**Infrastructure as Code (IaC)** means defining your servers, databases, and networks in code files (like Terraform), instead of clicking buttons in a web interface.

**Why it matters:**
- **Version Control** - Track changes to infrastructure like code
- **Reproducible** - Same infrastructure every time
- **Automated** - No manual clicking, less human error
- **Documented** - Code shows exactly what you have

**Example:**
Instead of manually creating an EC2 instance in AWS console, you write:
```hcl
resource "aws_instance" "app" {
  instance_type = "t2.micro"
  ami           = "ami-12345"
}
```

Then run `terraform apply` and it creates the server automatically!

---

### What is Observability?

**Observability** means understanding what your application is doing:
- **Metrics** - Numbers (CPU usage, memory, requests per second)
- **Logs** - Text messages (errors, info)
- **Traces** - Request paths through your system

**Why it matters:**
- **Debug faster** - Know exactly what's wrong
- **Prevent crashes** - See problems before they happen
- **Optimize** - Find bottlenecks and fix them
- **Alert** - Get notified when things break

**Prometheus** collects metrics (like how much RAM your app uses) and stores them so you can visualize and alert on them.

---

### What We'll Build

1. **Terraform Configuration**
   - Define AWS EC2 instance in code
   - Configure security groups (firewall rules)
   - Set up networking

2. **EC2 Instance**
   - Small virtual server (t2.micro - free tier eligible)
   - Run your Docker containerized app
   - Accessible from the internet

3. **Prometheus**
   - Monitor your app's metrics
   - Track RAM, CPU, request rates
   - Visualize in Grafana (optional, but cool!)

---

### Prerequisites

Before we start, you'll need:

1. **AWS Account** (Free Tier)
   - Sign up: https://aws.amazon.com/free/
   - Free tier includes: 750 hours/month of t2.micro EC2
   - You'll need a credit card (won't be charged if you stay in free tier)

2. **AWS CLI** (optional, but helpful)
   - Install: https://aws.amazon.com/cli/
   - Configure: `aws configure`
   - Or use environment variables (see below)

3. **Terraform** (we'll install this)
   - Infrastructure as Code tool
   - We'll install it in the project

---

### Stage 4: Step-by-Step Implementation

#### Step 1: Install Terraform

**What is Terraform?**
Terraform is a tool that lets you define infrastructure in code and deploy it to cloud providers (AWS, Azure, GCP, etc.).

**Installation:**

**macOS:**
```bash
brew install terraform
```

**Linux:**
```bash
# Download from: https://www.terraform.io/downloads
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

**Verify:**
```bash
terraform version
```

---

#### Step 2: Set Up AWS Credentials

**Option 1: AWS CLI (Recommended)**
```bash
# Install AWS CLI
# macOS: brew install awscli
# Then configure:
aws configure
```

You'll need:
- **AWS Access Key ID** - Get from AWS Console → IAM → Users → Security Credentials
- **AWS Secret Access Key** - Created when you create access key
- **Default region** - e.g., `us-east-1`
- **Output format** - `json`

**Option 2: Environment Variables**
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

**How to get AWS credentials:**
1. Go to AWS Console: https://console.aws.amazon.com
2. Click your username → "Security credentials"
3. Scroll to "Access keys" → "Create access key"
4. Download the keys (you won't see the secret again!)

---

#### Step 3: Generate SSH Key Pair

**Why?** You need an SSH key to securely access your EC2 instance.

**Generate the key:**
```bash
cd "/Users/georgekariuki/Desktop/Inventory API"
./scripts/setup-ssh-key.sh
```

This creates:
- `.ssh/id_rsa` - Private key (keep secret!)
- `.ssh/id_rsa.pub` - Public key (Terraform uploads this to AWS)

**What happens:**
- Terraform will upload the public key to AWS
- AWS will install it on your EC2 instance
- You can SSH in using the private key

---

#### Step 4: Update Docker Image Reference

**Before deploying, update the user_data.sh script:**

Edit `terraform/user_data.sh` and replace `YOUR_DOCKER_USERNAME` with your actual Docker Hub username:

```bash
# Find this line in user_data.sh:
image: YOUR_DOCKER_USERNAME/inventory-api:latest

# Replace with your Docker Hub username:
image: georgekariuki/inventory-api:latest
```

---

#### Step 5: Initialize Terraform

**Navigate to terraform directory:**
```bash
cd terraform
```

**Initialize Terraform:**
```bash
terraform init
```

**What this does:**
- Downloads AWS provider plugin
- Sets up Terraform backend
- Prepares for deployment

**Expected output:**
```
Initializing provider plugins...
Terraform has been successfully initialized!
```

---

#### Step 6: Plan the Deployment

**See what Terraform will create:**
```bash
terraform plan
```

**What this does:**
- Shows you exactly what resources will be created
- Checks for errors before deploying
- Shows you the changes

**Review the plan:**
- 1 EC2 instance (t2.micro)
- 1 Security Group (firewall rules)
- 1 Key Pair (SSH access)

---

#### Step 7: Deploy Infrastructure

**Create the resources:**
```bash
terraform apply
```

**What happens:**
- Terraform asks for confirmation (type `yes`)
- Creates EC2 instance in AWS
- Sets up security groups
- Uploads SSH key
- Runs user_data.sh script (installs Docker, etc.)

**This takes 2-3 minutes!**

**After completion, you'll see:**
```
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

instance_public_ip = "54.123.45.67"
api_url = "http://54.123.45.67:8000"
prometheus_url = "http://54.123.45.67:9090"
ssh_command = "ssh -i ../.ssh/id_rsa ec2-user@54.123.45.67"
```

---

#### Step 8: Deploy Your App on EC2

**SSH into your EC2 instance:**
```bash
# Use the command from terraform output, or:
ssh -i ../.ssh/id_rsa ec2-user@<YOUR_EC2_IP>
```

**Once connected, update docker-compose.yml:**
```bash
cd /home/ec2-user/inventory-api
nano docker-compose.yml
# Replace YOUR_DOCKER_USERNAME with your Docker Hub username
```

**Start the services:**
```bash
docker-compose up -d
```

**Check status:**
```bash
docker-compose ps
docker-compose logs -f
```

---

#### Step 9: Access Your Services

**Your Inventory API:**
- URL: `http://<EC2_IP>:8000`
- Docs: `http://<EC2_IP>:8000/docs`

**Prometheus:**
- URL: `http://<EC2_IP>:9090`
- Explore metrics: Go to Status → Targets (see what's being monitored)

**Test the API:**
```bash
curl http://<EC2_IP>:8000/health
curl http://<EC2_IP>:8000/products/
```

---

#### Step 10: Add Metrics Endpoint to Your App

**We need to expose metrics for Prometheus to scrape.**

**Install prometheus-client:**
```bash
# Add to pyproject.toml
poetry add prometheus-client
```

**Add metrics endpoint to FastAPI:**
```python
# In app/main.py
from prometheus_client import generate_latest, CONTENT_TYPE_LATEST
from fastapi.responses import Response

@app.get("/metrics")
async def metrics():
    return Response(content=generate_latest(), media_type=CONTENT_TYPE_LATEST)
```

**Rebuild and push Docker image:**
```bash
docker build -t YOUR_USERNAME/inventory-api:latest .
docker push YOUR_USERNAME/inventory-api:latest
```

**Update on EC2:**
```bash
ssh into EC2
cd /home/ec2-user/inventory-api
docker-compose pull app
docker-compose up -d app
```

---

### Understanding the Files (Stage 4)

#### `terraform/main.tf`
- **Defines infrastructure** - EC2 instance, security groups, networking
- **Uses data sources** - Finds latest Amazon Linux AMI automatically
- **Creates resources** - Everything needed to run your app

#### `terraform/variables.tf`
- **Configurable values** - Region, instance type, project name
- **Easy to change** - Modify defaults or pass via command line

#### `terraform/user_data.sh`
- **Runs on startup** - Executes when EC2 instance first boots
- **Installs software** - Docker, Docker Compose
- **Sets up services** - Creates docker-compose.yml, Prometheus config

#### `prometheus/prometheus.yml`
- **Monitoring config** - What to scrape, how often
- **Target definitions** - Where your services are
- **Scrape intervals** - How frequently to collect metrics

---

### Terraform Commands Reference

```bash
# Initialize Terraform
terraform init

# See what will be created
terraform plan

# Create infrastructure
terraform apply

# Destroy everything (careful!)
terraform destroy

# Show current state
terraform show

# List resources
terraform state list

# Get output values
terraform output
```

---

### Monitoring with Prometheus

**Access Prometheus UI:**
- Go to: `http://<EC2_IP>:9090`

**Useful queries:**
```
# CPU usage
rate(process_cpu_seconds_total[5m])

# Memory usage
process_resident_memory_bytes

# HTTP requests
http_requests_total

# Request rate
rate(http_requests_total[5m])
```

**View targets:**
- Status → Targets
- See if Prometheus can reach your services

---

### Stage 4: Quick Start Guide

#### Quick Setup (5 Steps)

**Step 1: Install Terraform**
```bash
# macOS
brew install terraform

# Verify
terraform version
```

**Step 2: Set Up AWS Credentials**
```bash
# Option 1: AWS CLI
aws configure
# Enter: Access Key ID, Secret Key, Region (us-east-1), Format (json)

# Option 2: Environment Variables
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
export AWS_DEFAULT_REGION="us-east-1"
```

**Step 3: Generate SSH Key**
```bash
cd "/Users/georgekariuki/Desktop/Inventory API"
./scripts/setup-ssh-key.sh
```

**Step 4: Deploy Infrastructure**
```bash
cd terraform
terraform init
terraform plan    # Review what will be created
terraform apply   # Type 'yes' to confirm
```

**Step 5: Deploy Your App**
```bash
# SSH into EC2 (use IP from terraform output)
ssh -i ../.ssh/id_rsa ec2-user@<EC2_IP>

# Once connected:
cd /home/ec2-user/inventory-api
nano docker-compose.yml  # Replace YOUR_DOCKER_USERNAME
docker-compose up -d
```

#### Verify Everything Works

**Your API:**
```bash
curl http://<EC2_IP>:8000/health
curl http://<EC2_IP>:8000/docs
```

**Prometheus:**
- Open: `http://<EC2_IP>:9090`
- Go to: Status → Targets
- Should see: `inventory-api` and `prometheus` as UP

#### Clean Up

```bash
cd terraform
terraform destroy  # Removes everything
```

#### Prerequisites Checklist

- [ ] AWS Account created
- [ ] AWS Access Key generated
- [ ] Terraform installed
- [ ] SSH key generated
- [ ] Docker image pushed to Docker Hub
- [ ] Updated docker-compose.yml with your Docker Hub username

#### Important URLs

After deployment, you'll have:
- **API:** `http://<EC2_IP>:8000`
- **API Docs:** `http://<EC2_IP>:8000/docs`
- **Metrics:** `http://<EC2_IP>:8000/metrics`
- **Prometheus:** `http://<EC2_IP>:9090`

---

### What We've Accomplished in Stage 4

#### Files Created

**Terraform Configuration:**
- `terraform/main.tf` - Main infrastructure definition
- `terraform/variables.tf` - Configurable values
- `terraform/user_data.sh` - Startup script
- `terraform/.gitignore` - Excludes sensitive files

**Prometheus Configuration:**
- `prometheus/prometheus.yml` - Monitoring configuration

**Scripts:**
- `scripts/setup-ssh-key.sh` - SSH key generator

**Application Updates:**
- `app/main.py` - Added `/metrics` endpoint
- `pyproject.toml` - Added `prometheus-client` dependency

#### What Each Component Does

**1. Terraform (`terraform/main.tf`)**
- **Purpose:** Define infrastructure in code
- **Key Resources:**
  - `aws_instance.app` - Creates the EC2 virtual server
  - `aws_security_group.app_sg` - Firewall rules (ports 22, 8000, 9090)
  - `aws_key_pair.app_key` - SSH key for secure access
  - `data.aws_ami.amazon_linux` - Finds latest Amazon Linux image
- **Why it's powerful:**
  - Version controlled infrastructure
  - Reproducible deployments
  - No manual clicking in AWS console

**2. Security Group (`aws_security_group`)**
- **Purpose:** Firewall for your EC2 instance
- **Rules:**
  - **Port 22 (SSH)** - Allows you to connect to the server
  - **Port 8000 (HTTP)** - Your Inventory API
  - **Port 9090 (Prometheus)** - Metrics dashboard
- **Why it matters:**
  - Controls what traffic can reach your server
  - Security best practice
  - Prevents unauthorized access

**3. User Data Script (`user_data.sh`)**
- **Purpose:** Automates server setup
- **What it does:**
  1. Updates system packages
  2. Installs Docker
  3. Installs Docker Compose
  4. Creates docker-compose.yml
  5. Sets up Prometheus config
- **Why it's useful:**
  - No manual server configuration
  - Consistent setup every time
  - Runs automatically on boot

**4. Prometheus (`prometheus/prometheus.yml`)**
- **Purpose:** Collect and store metrics
- **What it monitors:**
  - Your Inventory API (`/metrics` endpoint)
  - Prometheus itself
  - System metrics (if you add node-exporter)
- **Why it's important:**
  - See how much RAM/CPU your app uses
  - Track request rates
  - Identify performance issues
  - Set up alerts

**5. Metrics Endpoint (`/metrics`)**
- **Purpose:** Expose application metrics
- **What it provides:**
  - Process metrics (CPU, memory)
  - HTTP metrics (requests, latency)
  - Custom metrics (you can add more)
- **How Prometheus uses it:**
  - Scrapes `/metrics` every 15 seconds
  - Stores data in time-series database
  - Makes it queryable via PromQL

---

### How It All Works Together

```
1. You run: terraform apply
   ↓
2. Terraform creates EC2 instance in AWS
   ↓
3. EC2 instance boots and runs user_data.sh
   ↓
4. Docker and Docker Compose are installed
   ↓
5. docker-compose.yml is created
   ↓
6. You SSH in and run: docker-compose up -d
   ↓
7. Your app starts on port 8000
   ↓
8. Prometheus starts on port 9090
   ↓
9. Prometheus scrapes /metrics from your app
   ↓
10. You can view metrics in Prometheus UI!
```

---

### What You Can Monitor

**Basic Metrics (automatic):**
- `process_cpu_seconds_total` - CPU usage
- `process_resident_memory_bytes` - RAM usage
- `process_start_time_seconds` - When app started
- `python_info` - Python version info

**HTTP Metrics (if you add middleware):**
- Request count
- Request duration
- Response status codes

**Custom Metrics (you can add):**
- Number of products in database
- API response times
- Error rates
- Database connection pool size

---

### Key Concepts Learned (Stage 4)

**Infrastructure as Code (IaC)**
- **Definition:** Infrastructure defined in code files
- **Tool:** Terraform
- **Benefit:** Version controlled, reproducible infrastructure

**Observability**
- **Definition:** Understanding what your app is doing
- **Tool:** Prometheus
- **Benefit:** Debug faster, prevent crashes, optimize performance

**Cloud Infrastructure**
- **AWS EC2:** Virtual servers in the cloud
- **Security Groups:** Firewall rules
- **Key Pairs:** Secure SSH access

**Monitoring**
- **Metrics:** Numerical data (CPU, RAM, requests)
- **Scraping:** Prometheus collects metrics periodically
- **Time-series:** Data stored with timestamps

---

### Troubleshooting (Stage 4)

**Terraform errors:**
- Check AWS credentials: `aws sts get-caller-identity`
- Verify region is correct
- Check SSH key exists: `ls -la .ssh/id_rsa.pub`

**EC2 connection issues:**
- Wait 2-3 minutes after creation (instance needs to boot)
- Check security group allows SSH (port 22)
- Verify key pair is correct

**App not accessible:**
- Check security group allows port 8000
- Verify Docker containers are running: `docker ps`
- Check logs: `docker-compose logs`

**Prometheus not scraping:**
- Verify Prometheus config: `docker-compose exec prometheus cat /etc/prometheus/prometheus.yml`
- Check targets: Prometheus UI → Status → Targets
- Ensure /metrics endpoint exists on your app

---

### Clean Up (Important!)

**To avoid AWS charges, destroy resources when done:**

```bash
cd terraform
terraform destroy
```

**This will:**
- Terminate EC2 instance
- Delete security group
- Remove key pair
- **Free tier:** No charges if you stay within limits

---

### Next Steps for Stage 4

- [ ] Add Grafana for visualization (beautiful dashboards!)
- [ ] Set up alerts (notify when metrics exceed thresholds)
- [ ] Add more metrics (database connections, response times)
- [ ] Use Terraform Cloud for remote state
- [ ] Add multiple environments (dev, staging, prod)

---

### Resources

- **Terraform Docs:** https://www.terraform.io/docs
- **AWS EC2 Docs:** https://docs.aws.amazon.com/ec2/
- **Prometheus Docs:** https://prometheus.io/docs/
- **AWS Free Tier:** https://aws.amazon.com/free/
- **Prometheus Client Python:** https://github.com/prometheus/client_python

---

**Congratulations!** 🎉 You've completed all 4 stages and learned Backend Development, Docker, CI/CD, and Infrastructure as Code!

