CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    login VARCHAR(50) NOT NULL,
    age INT CHECK (age >= 16),
    gpa decimal(4,2),
    major VARCHAR(50)
);

CREATE TABLE Faculty (
    faculty_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    department VARCHAR(50)
);

CREATE TABLE Courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    credits INT CHECK (credits > 0)
);

CREATE TABLE Rooms (
    room_number VARCHAR(10) PRIMARY KEY,
    building VARCHAR(50),
    capacity INT CHECK (capacity > 0)
);

CREATE TABLE Enrolled (
    student_id INT,
    course_id INT,
    semester VARCHAR(10),
    grade CHAR(2),
    PRIMARY KEY (student_id, course_id, semester),
    FOREIGN KEY (student_id) REFERENCES Students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id) ON DELETE CASCADE
);


CREATE TABLE Teaches (
    faculty_id INT,
    course_id INT,
    semester VARCHAR(10),
    PRIMARY KEY (faculty_id, course_id, semester),
    FOREIGN KEY (faculty_id) REFERENCES Faculty(faculty_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id) ON DELETE CASCADE
);

CREATE TABLE Meets_In (
    course_id INT,
    room_number VARCHAR(10),
    semester VARCHAR(10),
    time_slot VARCHAR(20),
    PRIMARY KEY (course_id, semester, time_slot),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id) ON DELETE CASCADE,
    FOREIGN KEY (room_number) REFERENCES Rooms(room_number) ON DELETE SET NULL
);



INSERT INTO Students(student_id,name,login,age,gpa,major)
values
(1,'Krishna','krish@123',25,9.30,'Computer');

INSERT INTO Students(student_id,name,login,age,gpa,major)
values
(5000,'Dave','dave@cs',19,3.3,'Computer'),
(53666,'Jones','jones@cs',18,3.4,'Computer'),
(53688,'Smith','smith@ee',18,3.2,'Electronics'),
(53650,'Smith','smith@math',19,3.8,'Mathematics'),
(58322,'Guldu','guldu@music',16,2.0,'Music');
