/*
	SUB-QUERIES / NESTED QUERIES => Quary inside a query
   ==============================
	-> One Query is called Inner/ child / Sub-Query
	-> Other query is called outer / parent / main - query
	-> Use sub-query when where cond based on unknown value

	 Types of sub-queries 
    **********************
	1) Non Co-related sub-queries
    2) Co-related sub-queries 
    3) Derived tables and CTEs
    4) Scalar sub-queries 
*/

/*
	1. Non Co-related sub-queries 
	==============================
	-> In Non Co-related Queries, Excution starts form Inner Query.
	-> Inner Query executed only one time.
	Ex:- SELECT Ename FROM Employees WHERE Sal=(SELECT MAX(Sal) FROM Employees)
										   ----------------------------------
												|
										Inner Query Executes only one time 

	-> Outer Query takes input, and inner query act as input here.
 
	Syntax
	********
		SELECT columns FROM TableName WHERE Colname Operateor (SELECT statement) 
		-------------------------------------------		      ------------------
		      |												     |
	   Outer/parent/main Query			               Inner/child/Sub Query

	-> Operator must be any "Relational operator" like  [=, >, >=, <, <=, <>] 

Table Used :- Employee
*/
Select * From Employee 

--Employees earning more than blake ?
Select * From Employee Where Sal>(Select Sal From Employee Where ENAME='Blake')

--Employees who are senior to king ?
Select * From Employee Where Hiredate<(Select Hiredate From Employee Where Ename='King')

--Employee name earning max salary ?
Select * From Employee Where Sal=(Select Max(Sal) From Employee)

--Employee having max experience ?
Select * From Employee Where Hiredate=(Select Min(Hiredate) From Employee)

-- Top 5 Max Salaries
Select distinct top 5 Sal from Employee Order by Sal Desc

--Display 2nd max salary ? 
Select Max(Sal) as [Second MinSal] From Employee Where Sal!=(Select Max(Sal) From Employee)

--Name of the employee earning 2nd max sal ?
Select * From Employee Where Sal=(Select Max(Sal) From Employee Where Sal!=(Select Max(Sal) From Employee))


/*
	# Multi-Row Sub-Queries 
	=========================
	-> If sub-query returns more than one value then it is called multi-row sub-query

	Syntax
    -------		
		SELECT columns FROM TableName WHERE Colname Operateor (SELECT statement)  

	-> Operateor must be [ IN , NOT IN , ANY , ALL ] , this operators work mulitple values

			Single Value	     Multi Value 
          --------------		-------------
			=					IN (act as Equal to with muliple values)
			<> or !=			NOT IN (act as Not Equal to with muliple values)
			>					>ANY, >ALL (act as Greater than with multiples value)
			<					<ANY, <ALL (act as Less than with multiples value)

Table Used :- Employee, Dept  
*/
Select * From Employee
Select * from Dept

--Employees working at NEW YORK,CHICAGO locations ?
Select * From Employee Where Deptno IN(Select Deptno From Dept Where LOC IN ('New York','Chicago'))

--Employees not working at NEW YORK,CHICAGO locations ?
Select * From Employee Where Deptno NOT IN(Select Deptno From Dept Where LOC IN ('New York','Chicago'))

--Employees earning more than all managers ?
Select * From Employee Where Sal> All(Select Sal From Employee Where Job='Manager')

--Employees earning more than atleast one manager ?
Select * From Employee Where Sal> Any(Select Sal From Employee Where Job='Manager')


/*
	2. Co-related sub-queries 
	==========================
	-> If inner query uses referenes values of outer query then it is called co-related sub-query.

	Ex:-  SELECT *
     	      FROM emp as x WHERE sal > (SELECT AVG(sal) FROM emp WHERE deptno =  x.deptno)
						 ---													 ----------
						  |															|
	                  Outer Query								Inner Query Refers to Outer Query

	-> Execution starts from outer query and inner query is executed no of times depends on no. of rows return by outer query
	-> Use co-related sub-queries to execute sub-query for each row return by outer query.
	-> In Co-related sub-quaries, Both Outer Query and Inner Query taking values as input to each other, that's why this is called 
	   Co-related sub-query.

Table Used :- Employee
*/

--Employees earning more than avg sal of the organization ?
Select * From Employee as E Where Sal>(Select Avg(Sal) From Employee Where Deptno=E.DEPTNO)

--Employees earning max salary in their dept ? 
Select * From Employee as E Where Sal=(Select Max(Sal) From Employee Where Deptno=E.DEPTNO) Order By Deptno

--Display top 3 max salaries ? (without using Top Clause)
Select distinct A.Sal From Employee as A Where 3>(Select Count(distinct Sal) From Employee as B Where A.Sal<B.Sal) 
order by Sal desc

--Display 3rd max sal ?
Select distinct A.Sal From Employee as A Where 2=(Select Count(distinct Sal) From Employee as B Where A.Sal<B.Sal) 
order by Sal desc

/*
	EXISTS operator
	===============
	-> It is a special operator which is used in co-related subqeury only.
	-> This operator is used to check the required row / rows are existing in a table or not. If a row / rows are existing 
	   in a table then it returns TRUE otherwise return "FALSE".

	syntax:
	-------
		where exists(inner query);

Table Used :- Employee, Dept
*/

-- Display department details in which department the employees are working?
Select * From Dept as D Where Exists(Select Deptno From Employee Where DEPTNO=D.DEPTNO ) 

---- Display department details in which department the employees are not working?
Select * From Dept as D Where Not Exists(Select Deptno From Employee Where DEPTNO=D.DEPTNO ) 


/*
	3. Derived Tables 
	==================
	-> Sub-queries in FROM clause are called Derived tables 

	Syntax
   ********
		SELECT columns FROM (SELECT statement) as <alias> WHERE condition 

	-> Sub-query output acts like a table for outer query

	-> Derived tables are used in following scenarios 
		- To control the order of execution of clauses 
		- To use result of one operation in another operation
		- To join two query outputs 

Table Used  :- Employee
*/

-- Display top 3 ranks employees based on sal and highest paid should get 1st rank ?	 
Select * From (Select *,Dense_Rank() Over(Order By Sal Desc) as Rnk From Employee) as E Where E.Rnk<=3

--To display top 3 max salaries without using top Clause and Co-related subquery?
Select distinct Sal From (Select Sal,Dense_Rank() Over(Order By Sal Desc) as Rnk From Employee) as E Where E.Rnk<=3

--Display 5th max salaries ? 
Select Sal From (Select Sal,Dense_Rank() Over(Order By Sal Desc) as Rnk From Employee) as E Where E.Rnk=5

--Display even number rows from Employee Table?
Select * From (Select Row_Number() Over(Order By Empno Asc) as Rno,* From Employee) as E Where Rno%2=0

--Display last 3 rows ?
Select * From (Select Row_Number() Over(Order By Empno Asc) as Rno,* From Employee) as E Where Rno>=(Select count(*)-2 From Employee)


/*
	CTE (Common Table Expression)   
   ===============================
	-> In Derived tables "outer query cannot be dml" and it must be always select. To Solve this CTE concept introduced.
	-> Using CTE, we can give name to the query output and we can use that name in another query like select / insert / update / delete.
	-> CTEs can be use to solve complex queries

	Syntax
	********
		WITH <cte-name1> AS (SELECT statement), (cte-name2) AS (SELECT statement) SELECT/INSERT/UPDATE/DELETE Statements

*/

--Delete first 3 rows ?
With E as (Select Row_Number() Over(Order By Empno) as Rno,* From Employee)
Delete From E Where Rno<=3

/* Table Used:- Emp43*/
Select * From Emp43

--Delete duplicate rows ?
With E as (Select *,Row_Number() Over(Partition By Eno,Ename,Sal Order By Eno) as Rno From Emp43)
Delete From E Where Rno>1


/*
	4. Scalar Sub-Queries 
	========================
	-> Sub-queries in SELECT clause are called scalar sub-queries 
	-> Sub-query output acts like a column for outer query.
	-> Use scalar sub-query to show the query output in seperate column 
	
	Syntax
	--------
		SELECT (select stmt1), (select stmt2), (select stmt3) FROM tabname WHERE condition

Table Used :-  Display dept wise total salary ?
*/

-- Display DEPTNO, DEPT_TOTSAL, TOTSAL   ?
Select Deptno, Sum(Sal) as [Dept_TOTSAL],(Select Sum(Sal) From Employee) as [TOTSAL] From Employee Group By Deptno

--Display Deptno, Dept_Totsal, Totsal, PCT(%) of Salary paid from Total Salary spend on Employee?
Select Deptno, Sum(Sal) as [Dept_TOTSAL],(Select Sum(Sal) From Employee) as [TOTSAL],
(Sum(Sal)/(Select Sum(Sal) From Employee))*100 as [PCT%] From Employee Group By Deptno