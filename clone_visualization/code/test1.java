/*
 * Created on 01.06.2006
 */
package smallsql.tools;

/**
 * @author Volker Berlin
 */
public class CommandLine {

    private static void printRS(ResultSet rs) throws SQLException {
        ResultSetMetaData md = rs.getMetaData();
        int count = md.getColumnCount();
        for(int i=1; i<=count; i++){
            System.out.print(md.getColumnLabel(i));
            System.out.print('\t');
        }
        System.out.println();
        while(rs.next()){
            for(int i=1; i<=count; i++){
                System.out.print(rs.getObject(i));
                System.out.print('\t');
            }
            System.out.println();
        }
    }
}
