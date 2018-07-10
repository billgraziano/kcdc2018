using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EFApp
{
    class Program
    {
        static void Main(string[] args)
        {

            HardCoded();

            PrintRegion("MO", 10);

            Console.WriteLine("Press any key to continue...");
            Console.ReadKey();
        }

        static void HardCoded()
        {
            Console.WriteLine("=== Hard-coded ============");
            var db = new AW();
            var q = from b in db.SalesOrderHeaders
                    orderby b.OrderDate
                    where b.RegionCode.Equals("KS")
                    select b;

            foreach (var i in q)
            {
                Console.WriteLine("{0} - {1} - {2}",
                    i.SalesOrderNumber,
                    i.OrderDate.ToShortDateString(),
                    i.RegionCode);
            }
        }

        static void PrintRegion(string state, int count)
        {
            Console.WriteLine("=== {0} ============", state);
            var db = new AW();
            var q = (from b in db.SalesOrderHeaders
                    orderby b.OrderDate
                    where b.RegionCode.Equals(state)
                    select b).Take(count);

            foreach (var i in q)
            {
                Console.WriteLine("{0} - {1} - {2}",
                    i.SalesOrderNumber,
                    i.OrderDate.ToShortDateString(),
                    i.RegionCode);
            }

            Console.WriteLine("");
        }
    }
}
