import pytest
from fastapi import status

def test_create_product(client):
    response = client.post(
        "/products/",
        json={
            "name": "Test Laptop",
            "description": "A test laptop",
            "quantity": 10,
            "price": 999.99
        }
    )
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["name"] == "Test Laptop"
    assert data["description"] == "A test laptop"
    assert data["quantity"] == 10
    assert data["price"] == 999.99
    assert "id" in data
    assert "created_at" in data
    assert "updated_at" in data

def test_create_product_minimal(client):
    response = client.post(
        "/products/",
        json={
            "name": "Minimal Product",
            "price": 50.0
        }
    )
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["name"] == "Minimal Product"
    assert data["quantity"] == 0
    assert data["description"] is None

def test_get_products_empty(client):
    response = client.get("/products/")
    assert response.status_code == status.HTTP_200_OK
    assert response.json() == []

def test_get_products(client):
    client.post(
        "/products/",
        json={"name": "Product 1", "price": 10.0}
    )
    client.post(
        "/products/",
        json={"name": "Product 2", "price": 20.0}
    )
    
    response = client.get("/products/")
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert len(data) == 2
    assert data[0]["name"] in ["Product 1", "Product 2"]
    assert data[1]["name"] in ["Product 1", "Product 2"]

def test_get_product_by_id(client):
    create_response = client.post(
        "/products/",
        json={"name": "Single Product", "price": 100.0}
    )
    product_id = create_response.json()["id"]
    
    response = client.get(f"/products/{product_id}")
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["id"] == product_id
    assert data["name"] == "Single Product"
    assert data["price"] == 100.0

def test_get_product_not_found(client):
    response = client.get("/products/999")
    assert response.status_code == status.HTTP_404_NOT_FOUND
    assert "not found" in response.json()["detail"].lower()

def test_update_product(client):
    create_response = client.post(
        "/products/",
        json={"name": "Original Name", "quantity": 5, "price": 50.0}
    )
    product_id = create_response.json()["id"]
    original_updated_at = create_response.json()["updated_at"]
    
    response = client.put(
        f"/products/{product_id}",
        json={"quantity": 10}
    )
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["quantity"] == 10
    assert data["name"] == "Original Name"
    assert data["updated_at"] != original_updated_at

def test_update_product_all_fields(client):
    create_response = client.post(
        "/products/",
        json={"name": "Old Name", "description": "Old desc", "quantity": 1, "price": 10.0}
    )
    product_id = create_response.json()["id"]
    
    response = client.put(
        f"/products/{product_id}",
        json={
            "name": "New Name",
            "description": "New description",
            "quantity": 20,
            "price": 200.0
        }
    )
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["name"] == "New Name"
    assert data["description"] == "New description"
    assert data["quantity"] == 20
    assert data["price"] == 200.0

def test_update_product_not_found(client):
    response = client.put(
        "/products/999",
        json={"name": "New Name"}
    )
    assert response.status_code == status.HTTP_404_NOT_FOUND

def test_delete_product(client):
    create_response = client.post(
        "/products/",
        json={"name": "To Delete", "price": 30.0}
    )
    product_id = create_response.json()["id"]
    
    response = client.delete(f"/products/{product_id}")
    assert response.status_code == status.HTTP_204_NO_CONTENT
    
    get_response = client.get(f"/products/{product_id}")
    assert get_response.status_code == status.HTTP_404_NOT_FOUND

def test_delete_product_not_found(client):
    response = client.delete("/products/999")
    assert response.status_code == status.HTTP_404_NOT_FOUND

def test_create_product_validation_errors(client):
    response = client.post(
        "/products/",
        json={"name": ""}
    )
    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY

def test_create_product_negative_price(client):
    response = client.post(
        "/products/",
        json={"name": "Product", "price": -10.0}
    )
    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY

def test_create_product_negative_quantity(client):
    response = client.post(
        "/products/",
        json={"name": "Product", "price": 10.0, "quantity": -5}
    )
    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY

