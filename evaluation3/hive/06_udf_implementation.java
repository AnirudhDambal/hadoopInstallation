// ============================================
// Apache Hive UDF: Custom Data Handling
// ============================================
// This UDF demonstrates:
// 1. Creating a simple UDF for custom string manipulation
// 2. Converting employee names to uppercase and adding prefix
// ============================================

import org.apache.hadoop.hive.ql.exec.UDF;
import org.apache.hadoop.io.Text;

public class EmployeeFormatterUDF extends UDF {
    
    /**
     * This UDF formats employee names by:
     * 1. Converting to uppercase
     * 2. Adding a prefix "EMP: "
     * 
     * @param input - Input employee name
     * @return Formatted employee name
     */
    public Text evaluate(Text input) {
        if (input == null || input.toString().trim().isEmpty()) {
            return new Text("EMP: UNKNOWN");
        }
        
        String name = input.toString().trim().toUpperCase();
        return new Text("EMP: " + name);
    }
    
    /**
     * Overloaded method for String input
     */
    public Text evaluate(String input) {
        if (input == null || input.trim().isEmpty()) {
            return new Text("EMP: UNKNOWN");
        }
        
        String name = input.trim().toUpperCase();
        return new Text("EMP: " + name);
    }
}

