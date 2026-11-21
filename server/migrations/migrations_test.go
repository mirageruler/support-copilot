package migrations_test

import (
	"database/sql"
	"os"
	"testing"

	_ "github.com/jackc/pgx/v5/stdlib"
)

func TestVectorExtensionInstalled(t *testing.T) {
	url := os.Getenv("TEST_DATABASE_URL")
	if url == "" {
		t.Fatal("TEST_DATABASE_URL is not set; run tests with make test")
	}

	db, err := sql.Open("pgx", url)
	if err != nil {
		t.Fatalf("open db: %v", err)
	}
	t.Cleanup(func() {
		db.Close()
	})

	var ok bool
	if err := db.QueryRowContext(t.Context(), "SELECT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'vector')").Scan(&ok); err != nil {
		t.Fatalf("query extension: %v", err)
	}

	if !ok {
		t.Fatal("vector extension is not installed")
	}
}
