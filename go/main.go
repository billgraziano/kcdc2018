package main

import (
	"bufio"
	"database/sql"
	"fmt"
	"log"
	"os"
	"time"

	_ "github.com/alexbrainman/odbc"
)

func main() {
	var (
		ordernum  string
		orderdate time.Time
		region    string
	)

	// Open the connection
	db, err := sql.Open("odbc",
		"Driver={SQL Server Native Client 11.0}; Server=.\\SQL2016; Database=AdventureWorks2016; Trusted_Connection=yes; App=AppRaw_GO;")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	stmt := `SELECT TOP 10 SalesOrderNumber, OrderDate, RegionCode 
			FROM    Sales.SalesOrderHeader 
			WHERE   RegionCode = ?`

	// Run the query
	rows, err := db.Query(stmt, "MO")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	// Process the results
	for rows.Next() {
		err := rows.Scan(&ordernum, &orderdate, &region)
		if err != nil {
			log.Fatal(err)
		}
		fmt.Println(ordernum, " - ", orderdate, " - ", region)
	}

	// Last error check
	err = rows.Err()
	if err != nil {
		log.Fatal(err)
	}

	pressEnter()

}

func pressEnter() {
	fmt.Println("Press enter to continue...")
	reader := bufio.NewReader(os.Stdin)
	reader.ReadString('\n')
}
