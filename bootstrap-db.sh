docker run --name postgres-test -e POSTGRES_DB=vapor-test \
    -e POSTGRES_USER=vapor -e POSTGRES_PASSWORD=password \
    -p 5433:5432 -d postgres
