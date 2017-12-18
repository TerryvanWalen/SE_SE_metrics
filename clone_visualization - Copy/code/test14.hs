/*
 * Created on 31.06.2006
 */
package smallsql.tools;

import java.io.*;
import java.sql.*;
import java.util.Properties;

import javax.swing.JOptionPane;

import smallsql.database.*;


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
