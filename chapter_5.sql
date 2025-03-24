
-- create
 -- Create Sailors Table
CREATE TABLE Sailors (
    sid INTEGER PRIMARY KEY,        -- Unique identifier for sailors
    sname VARCHAR(100) NOT NULL,    -- Sailor's name
    rating INTEGER,                 -- Sailor's rating
    age REAL                        -- Sailor's age
);

-- Create Boats Table
CREATE TABLE Boats (
    bid INTEGER PRIMARY KEY,        -- Unique identifier for boats
    bname VARCHAR(100) NOT NULL,    -- Boat's name
    color VARCHAR(50)               -- Boat's color
);

-- Create Reserves Table
CREATE TABLE Reserves (
    sid INTEGER,                    -- Sailor's ID (foreign key)
    bid INTEGER,                    -- Boat's ID (foreign key)
    day DATE,                       -- Reservation day
    PRIMARY KEY (sid, bid, day),    -- Composite primary key (sailor, boat, and day)
    FOREIGN KEY (sid) REFERENCES Sailors(sid) ON DELETE CASCADE,  -- Foreign key to Sailors table
    FOREIGN KEY (bid) REFERENCES Boats(bid) ON DELETE CASCADE    -- Foreign key to Boats table
);

-- Insert Data into Sailors Table
INSERT INTO Sailors (sid, sname, rating, age) VALUES
(1, 'John Doe', 5, 25.5),
(2, 'Jane Smith', 7, 30.0),
(3, 'Bob Brown', 3, 22.5),
(4, 'Alice Johnson', 8, 28.0);

-- Insert Data into Boats Table
INSERT INTO Boats (bid, bname, color) VALUES
(1, 'Boat A', 'Red'),
(2, 'Boat B', 'Blue'),
(3, 'Boat C', 'Green'),
(4, 'Boat D', 'Yellow');

-- Insert Data into Reserves Table
INSERT INTO Reserves (sid, bid, day) VALUES
(1, 1, '2025-03-21'),
(1, 2, '2025-03-22'),
(2, 3, '2025-03-21'),
(3, 1, '2025-03-23'),
(4, 4, '2025-03-20');

select * from Sailors;
select * from Reserves;
select * from Boats;



select sname, color from Sailors s join Reserves r on s.sid=r.sid join Boats b on r.bid=b.bid
where color = 'red'or color='green';


select sname, color from Sailors s join Reserves r on s.sid=r.sid join Boats b on r.bid=b.bid
where color = 'red'
union
select sname, color from Sailors s join Reserves r on s.sid=r.sid join Boats b on r.bid=b.bid
where color = 'Green'; 



SELECT S.sname
FROM Sailors S, Reserves R, Boats B
WHERE S.sid = R.sid AND R.bid = B.bid AND B.color = 'red'
INTERSECT
SELECT S2.sname
FROM Sailors S2, Boats B2, Reserves R2
WHERE S2.sid = R2.sid AND R2.bid = B2.bid AND B2.color = 'green';


select s.sid from Sailors s join Reserves r on s.sid = r.sid WHERE rating > 5 or bid = 1;


select sid from Sailors where rating > 5
union
select sid from Reserves where bid=1;

Find the names of sailors who have reserved boat 2.
select sname from Sailors where sid in
(select sid from Reserves where bid=2);

select sname from Sailors where rating > (select rating from Sailors where sname = 'John Doe');


select sname, age from Sailors where age > (select max(age) from Sailors where rating=5);

select sname, min(age) from Sailors group by sname,rating; 

-- Create Student Table
CREATE TABLE Student (
    snum INT PRIMARY KEY,         -- Student Number (unique)
    sname VARCHAR(100),           -- Student Name
    major VARCHAR(50),            -- Student's Major (e.g., Computer Science, Engineering)
    level VARCHAR(50),            -- Level (e.g., Freshman, Sophomore, etc.)
    age INT                       -- Age of the Student
);

-- Create Faculty Table
CREATE TABLE Faculty (
    fid INT PRIMARY KEY,          -- Faculty ID (unique)
    fname VARCHAR(100),           -- Faculty Name
    deptid INT                    -- Department ID (foreign key referencing department)
);

-- Create Class Table
CREATE TABLE Class (
    cname VARCHAR(100),           -- Class Name (e.g., Math 101, CS 201)
    meets_at TIME,                -- Class meeting time (e.g., 10:00 AM)
    room VARCHAR(50),             -- Room number (e.g., 101, 202)
    fid INT,                      -- Faculty ID (foreign key referencing Faculty)
    PRIMARY KEY (cname, fid),     -- Composite primary key
    FOREIGN KEY (fid) REFERENCES Faculty(fid)
);

-- Create Enrolled Table
CREATE TABLE Enrolled (
    snum INT,                     -- Student Number (foreign key referencing Student)
    cname VARCHAR(100),           -- Class Name (foreign key referencing Class)
    PRIMARY KEY (snum, cname),    -- Composite primary key (student-class pair)
    FOREIGN KEY (snum) REFERENCES Student(snum),
    FOREIGN KEY (cname) REFERENCES Class(cname)
);




-- Insert Data into Student Table (including duplicates for demonstration)
INSERT INTO Student (snum, sname, major, level, age) VALUES
(1, 'Alice', 'Computer Science', 'Freshman', 19),
(2, 'Bob', 'Engineering', 'Sophomore', 20),
(3, 'Charlie', 'Mathematics', 'Junior', 21),
(6, 'Alice', 'Computer Science', 'Freshman', 19),  -- Duplicate (same student number, name, etc.)
(4, 'David', 'Physics', 'Senior', 22),
(5, 'Eva', 'Computer Science', 'Sophomore', 20);

-- Insert Data into Faculty Table (including duplicates for demonstration)
INSERT INTO Faculty (fid, fname, deptid) VALUES
(1, 'Dr. Smith', 101),
(2, 'Dr. Brown', 102),
(3, 'Dr. Clark', 101),
(5, 'Dr. Smith', 101),  -- Duplicate (same faculty ID and name)
(4, 'Dr. Wilson', 103);

-- Insert Data into Class Table (including duplicates for demonstration)
INSERT INTO Class (cname, meets_at, room, fid) VALUES
('Math 101', '09:00:00', '101', 1),
('CS 101', '10:00:00', '102', 2),
('Physics 101', '11:00:00', '103', 3),
('Chemistry 101', '12:00:00', '104', 4);

-- Insert Data into Enrolled Table (including duplicates for demonstration)
INSERT INTO Enrolled (snum, cname) VALUES
(1, 'Math 101'),
(1, 'CS 101'),  -- Alice is enrolled in two classes
(2, 'Math 101'),
(3, 'Physics 101'),
(4, 'Math 101'),
(5, 'CS 101'),
(3, 'Math 101'),  -- Duplicate (same student enrolling in the same class)
(2, 'Physics 101');

select distinct sname from Student s join Enrolled e on s.snum = e.snum join class c on e.cname = c.cname
where c.fid = 1 and s.level = 'Junior';

select sname, max(age) from Student s join enrolled e on s.snum = e.snum
join class c on e.cname = c.cname
join Faculty f on f.fid = c.fid
where s.major = 'Physics' or f.fname = 'Dr. Brown'
group by sname;


select c.cname from class c left join enrolled e on c.cname = e.cname
where c.room = '103'
group by c.cname
having count(e.snum) > 1;


select fname from Faculty f left join Class c on f.fid = c.fid
join enrolled e on c.cname = e.cname
group by fname
having count(e.snum) < 3;


select level, avg(age) from Student group by level;

select level, avg(age) from Student where level != 'Junior' group by level;

select sname from Student s left join enrolled e on s.snum = e.snum
group by sname
having count(e.snum) = (
select max(class_count) from (
select count(*) as class_count from Enrolled group by snum
) as class_counts);

SELECT S.sname
FROM Student S
LEFT JOIN Enrolled E ON S.snum = E.snum
WHERE E.snum IS NULL;





