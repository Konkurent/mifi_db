-- Задание 1
WITH RECURSIVE employee_hierarchy AS (SELECT e.employeeid,
                                             e.name,
                                             e.managerid,
                                             e.departmentid,
                                             e.roleid
                                      FROM employees e
                                      WHERE e.managerid = 1

                                      UNION ALL

                                      SELECT e.employeeid,
                                             e.name,
                                             e.managerid,
                                             e.departmentid,
                                             e.roleid
                                      FROM employees e
                                               INNER JOIN
                                           employee_hierarchy eh ON e.managerid = eh.employeeid)
                                        --    Строю дерево подчинунных Ивана Ивановича

SELECT eh.employeeid AS "EmployeeID",
       eh.name AS "EmployeeName",
       eh.managerid AS "ManagerID",
       d.departmentname AS "DepartmentName",
       r.rolename AS "RoleName",
       COALESCE(string_agg(DISTINCT p.projectname, ', '), 'NULL') AS "ProjectNames",
    --    Собираю проекты через запятую
       COALESCE(string_agg(DISTINCT t.taskname, ', '), 'NULL')    AS "TaskNames"
       --    Собираю задачи через запятую
FROM employee_hierarchy eh
         LEFT JOIN
     departments d ON eh.departmentid = d.departmentid
         LEFT JOIN
     roles r ON eh.roleid = r.roleid
         LEFT JOIN
     projects p ON p.departmentid = eh.departmentid
         LEFT JOIN
     tasks t ON t.assignedto = eh.employeeid
GROUP BY eh.employeeid, eh.name, eh.managerid, d.departmentname, r.rolename
ORDER BY eh.name;

-- Задание 2
WITH RECURSIVE employee_hierarchy AS (
    SELECT
        e.employeeid,
        e.name,
        e.managerid,
        e.departmentid,
        e.roleid
    FROM
        employees e
    WHERE
        e.managerid = 1

    UNION ALL

    SELECT
        e.employeeid,
        e.name,
        e.managerid,
        e.departmentid,
        e.roleid
    FROM
        employees e
    INNER JOIN
        employee_hierarchy eh ON e.managerid = eh.employeeid
)
--    Строю дерево подчинунных Ивана Ивановича

SELECT
    eh.employeeid AS "EmployeeID",
    eh.name AS "EmployeeName",
    eh.managerid AS "ManagerID",
    d.departmentname AS "DepartmentName",
    r.rolename AS "RoleName",
    COALESCE(string_agg(DISTINCT p.projectname, ', '), 'NULL') AS "ProjectNames",
    COALESCE(string_agg(DISTINCT t.taskname, ', '), 'NULL') AS "TaskNames",
    COUNT(t.taskid) AS "TotalTasks",
    (SELECT COUNT(*) FROM employees e WHERE e.managerid = eh.employeeid) AS "TotalSubordinates"
    -- Вывожу прямых подчиненных
FROM
    employee_hierarchy eh
LEFT JOIN
    departments d ON eh.departmentid = d.departmentid
LEFT JOIN
    roles r ON eh.roleid = r.roleid
LEFT JOIN
    projects p ON p.departmentid = eh.departmentid -- Assuming projects are associated with the department
LEFT JOIN
    tasks t ON t.assignedto = eh.employeeid
GROUP BY
    eh.employeeid, eh.name, eh.managerid, d.departmentname, r.rolename
ORDER BY
    eh.name;

-- Задание 3
WITH RECURSIVE employee_hierarchy AS (SELECT e.employeeid,
                                             e.name,
                                             e.managerid,
                                             e.departmentid,
                                             e.roleid,
                                             e.employeeid as root_id
                                      FROM employees e
                                      JOIN employees s ON e.managerid = s.employeeid
                                      WHERE e.roleid = 1

                                      UNION

                                      SELECT e.employeeid,
                                             e.name,
                                             e.managerid,
                                             e.departmentid,
                                             e.roleid,
                                            eh.root_id
                                      FROM employees e JOIN employee_hierarchy eh ON e.managerid = eh.employeeid
                                      ),
                                    --   Строю деревья прямых/непрямых подчинных меенеджеров с сохранением корневого элемента - менеджера
    subordinates_count AS (
        SELECT eh.root_id, COUNT(*) as count
        FROM employee_hierarchy eh
        WHERE employeeid != root_id
        GROUP BY eh.root_id
    )
    -- менеджера с кол-вом
SELECT eh.employeeid AS EmployeeID,
       eh.name AS EmployeeName,
       eh.managerid AS ManagerID,
       d.departmentname AS DepartmentName,
       r.rolename AS RoleName,
       COALESCE(string_agg(DISTINCT p.projectname, ', '), 'NULL') AS ProjectNames,
       COALESCE(string_agg(DISTINCT t.taskname, ', '), 'NULL')    AS TaskNames,
       (SELECT count FROM subordinates_count WHERE root_id = eh.employeeid) AS "TotalSubordinates"
    --    вывожу кол-во прямых/непрямых подчиненных 
FROM employee_hierarchy eh
         LEFT JOIN
     departments d ON eh.departmentid = d.departmentid
         LEFT JOIN
     roles r ON eh.roleid = r.roleid
         LEFT JOIN
     projects p ON p.departmentid = eh.departmentid
         LEFT JOIN
     tasks t ON t.assignedto = eh.employeeid
         LEFT JOIN
     employees sub ON sub.managerid = eh.employeeid
GROUP BY eh.employeeid, eh.name, eh.managerid, d.departmentname, r.rolename
HAVING COUNT(sub.employeeid) > 0
ORDER BY eh.name;
