apk add --no-cache jq
echo "Getting access token..."
ACCESS_TOKEN=$(http --ignore-stdin --form POST \
                http://polaris:8181/api/catalog/v1/oauth/tokens \
                grant_type=client_credentials \
                client_id=root \
                client_secret=secret \
                'scope=PRINCIPAL_ROLE:ALL' \
                | jq -r '.access_token') && echo "Access token: " $ACCESS_TOKEN

echo "Configuring Polaris catalog..."
http POST http://polaris:8181/api/management/v1/catalogs "Authorization: Bearer $ACCESS_TOKEN" <<EOF
{
    "name": "polariscatalog",
    "type": "INTERNAL",
    "properties": {
    "default-base-location": "s3://warehouse",
    "s3.endpoint": "http://minio:9000",
    "s3.path-style-access": "true",
    "s3.access-key-id": "admin",
    "s3.secret-access-key": "password",
    "s3.region": "dummy-region"
    },
    "storageConfigInfo": {
    "roleArn": "arn:aws:iam::000000000000:role/minio-polaris-role",
    "storageType": "S3",
    "allowedLocations": [
        "s3://warehouse/*"
    ]
    }
}
EOF

echo "Checking catalog..."
http GET http://polaris:8181/api/management/v1/catalogs "Authorization: Bearer $ACCESS_TOKEN"

echo "Setting up security..."
# Create a catalog admin role
http --ignore-stdin PUT http://polaris:8181/api/management/v1/catalogs/polariscatalog/catalog-roles/catalog_admin/grants \
  "Authorization: Bearer $ACCESS_TOKEN" \
  grant:='{"type":"catalog", "privilege":"CATALOG_MANAGE_CONTENT"}'

# Create a data engineer role
http --ignore-stdin POST http://polaris:8181/api/management/v1/principal-roles \
  "Authorization: Bearer $ACCESS_TOKEN" \
  principalRole:='{"name":"data_engineer"}'

# Connect the roles
http --ignore-stdin PUT http://polaris:8181/api/management/v1/principal-roles/data_engineer/catalog-roles/polariscatalog \
  "Authorization: Bearer $ACCESS_TOKEN" \
  catalogRole:='{"name":"catalog_admin"}'

# Give root the data engineer role
http --ignore-stdin PUT http://polaris:8181/api/management/v1/principals/root/principal-roles \
  "Authorization: Bearer $ACCESS_TOKEN" \
  principalRole:='{"name":"data_engineer"}'

echo "Check security"
http GET http://polaris:8181/api/management/v1/principals/root/principal-roles "Authorization: Bearer $ACCESS_TOKEN"

echo "Creating namespace 'rmoff'..."
http --ignore-stdin POST http://polaris:8181/api/catalog/v1/polariscatalog/namespaces \
  "Authorization: Bearer $ACCESS_TOKEN" \
  "Content-Type: application/json" \
  namespace:='["rmoff"]'
