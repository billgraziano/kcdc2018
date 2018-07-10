using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Configuration;
using System.Data.SqlClient;
using Dapper; 

namespace SQLApp
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("=== Raw SQL =============");
            RawQuery();

            Console.WriteLine("=== Dapper ==============");
            DapperQuery();

            Console.WriteLine("Press any key to continue...");
            Console.ReadKey();
        }

        static void RawQuery()
        {
            var cxnstring = System.Configuration.ConfigurationManager.ConnectionStrings["DB"].ConnectionString;
            using (var cxn = new SqlConnection(cxnstring))
            {
                string stmt = @"
                            SELECT TOP 10 SalesOrderNumber, OrderDate, RegionCode 
                            FROM    Sales.SalesOrderHeader 
                            WHERE   RegionCode = @region";
                SqlCommand cmd = new SqlCommand(stmt);
                SqlParameter regionParm = new SqlParameter("Region", System.Data.SqlDbType.Char, 2);
                regionParm.Value = "MO";
                
                cmd.Parameters.Add(regionParm);
                cmd.Connection = cxn;
                
                cxn.Open();

                using (SqlDataReader rdr = cmd.ExecuteReader(System.Data.CommandBehavior.CloseConnection))
                {
                    while (rdr.Read())
                    {
                        string ordernum = rdr.GetString(0);
                        DateTime orderdate = rdr.GetDateTime(1);
                        string region = rdr.GetString(2);
                        Console.WriteLine("{0} - {1} - {2}", ordernum, orderdate.ToShortDateString(), region);
                    }
                }
            }
        }

        static void DapperQuery()
        {
            var cxnstring = System.Configuration.ConfigurationManager.ConnectionStrings["ReadOnly"].ConnectionString;
            using (var cxn = new SqlConnection(cxnstring))
            {
                string stmt = @"
                        SELECT TOP 10 SalesOrderNumber, OrderDate, RegionCode 
                        FROM    Sales.SalesOrderHeader 
                        WHERE   RegionCode = @region";
                var result = cxn.Query<SalesOrderHeader>(stmt,
                    new { Region = new DbString { Value = "KS",
                                                IsFixedLength = true,
                                                Length = 2,
                                                IsAnsi = true } });
                foreach (var r in result)
                {
                    Console.WriteLine("{0} - {1} - {2}", r.SalesOrderNumber, r.OrderDate.ToShortDateString(), r.RegionCode);
                }
            }
        }

    }

    public class SalesOrderHeader
    {
        public string SalesOrderNumber { get; set; }
        public DateTime OrderDate { get; set; }
        public string RegionCode { get; set;  }
    }
}



