-- ============================
-- DATABASE SCHEMA: Table Setup
-- ============================

CREATE TABLE BOOK (
    Book_ID SERIAL PRIMARY KEY,
    Title VARCHAR(100) NOT NULL,
    Author VARCHAR(50) NOT NULL,
    ISBN VARCHAR(20) UNIQUE,
    Genre VARCHAR(30),
    TotalCopies INT CHECK (TotalCopies >= 0),
    PublicationYear INT
);

CREATE TABLE STUDENT (
    StudentID SERIAL PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    PhoneNumber VARCHAR(15),
    Major VARCHAR(50),
    DormNumber VARCHAR(10),
    MembershipDate DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE LIBRARIAN (
    LibrarianID SERIAL PRIMARY KEY,
    EmployeeID VARCHAR(50) UNIQUE NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE
);

CREATE TABLE LOAN (
    LoanID SERIAL PRIMARY KEY,
    Book_ID INT REFERENCES BOOK(Book_ID) ON DELETE CASCADE,
    StudentID INT REFERENCES STUDENT(StudentID) ON DELETE CASCADE,
    LibrarianID INT REFERENCES LIBRARIAN(LibrarianID) ON DELETE SET NULL,
    LoanDate DATE NOT NULL DEFAULT CURRENT_DATE,
    DueDate DATE NOT NULL CHECK (DueDate > LoanDate),
    ReturnDate DATE,
    FineAmount DECIMAL(10, 2) DEFAULT 0.00
);

-- BOOKS
INSERT INTO BOOK (Title, Author, ISBN, Genre, TotalCopies, PublicationYear) VALUES
('Echoes of the Nile', 'Amanuel Getachew', '9789994400172', 'Historical', 2, 1999),
('Code of the Ancients', 'Marta Girma', '9789994400173', 'Science Fiction', 1, 2021),
('Whispers in Addis', 'Biruk Tekle', '9789994400174', 'Drama', 0, 2018), -- Out of stock
('Digital Abyss', 'Selam Fikadu', '9789994400175', 'Technology', 5, 2023),
('Roots and Routes', 'Lemlem Ayele', '9789994400176', 'Biography', 4, 2011);

-- STUDENTS
INSERT INTO STUDENT (FirstName, LastName, Email, PhoneNumber, Major, DormNumber, MembershipDate) VALUES
('Rediet', 'Tadesse', 'rediet.t@aastu.edu.et', '0911556677', 'Data Science', 'Dorm C1', '2022-08-21'),
('Kalkidan', 'Mengistu', 'kalkidan.m@aastu.edu.et', '0922998899', 'Architecture', 'Dorm C3', '2023-02-12'),
('Samuel', 'Abate', 'samuel.a@aastu.edu.et', '0933997788', 'AI Engineering', 'Dorm C5', '2024-06-01');

-- LIBRARIANS
INSERT INTO LIBRARIAN (EmployeeID, FirstName, LastName, Email) VALUES
('LIB-104', 'Alemayehu', 'Zeleke', 'alemayehu.z@lib.edu.et'),
('LIB-105', 'Meskerem', 'Hailu', 'meskerem.h@lib.edu.et'),
('ADMIN-001', 'Ephrem', 'Tekle', 'ephrem.t@lib.edu.et');
-- LOAN
INSERT INTO LOAN (Book_ID, StudentID, LibrarianID, LoanDate, DueDate, ReturnDate) VALUES
(1, 1, 2, '2025-04-01', '2025-04-15', NULL),       -- LibrarianID 2 = LIB-105
(4, 3, 1, CURRENT_DATE, CURRENT_DATE + INTERVAL '14 days', NULL),  -- LibrarianID 1 = LIB-104
(2, 2, 3, '2025-03-01', '2025-03-15', '2025-03-14'); -- LibrarianID 3 = ADMIN-001



-- 1. Books that are out of stock
SELECT Title, Author FROM BOOK WHERE TotalCopies = 0;

-- 2. Students who borrowed books and haven't returned them yet
SELECT s.FirstName, s.LastName, b.Title, l.LoanDate, l.DueDate
FROM LOAN l
JOIN STUDENT s ON l.StudentID = s.StudentID
JOIN BOOK b ON l.Book_ID = b.Book_ID
WHERE l.ReturnDate IS NULL;

-- 3. Count how many books each librarian has processed
SELECT l.LibrarianID, lb.FirstName, lb.LastName, COUNT(*) AS LoanCount
FROM LOAN l
JOIN LIBRARIAN lb ON l.LibrarianID = lb.LibrarianID
GROUP BY l.LibrarianID, lb.FirstName, lb.LastName;

-- 4. Oldest and most recent books
SELECT Title, Author, PublicationYear FROM BOOK ORDER BY PublicationYear ASC LIMIT 1;  -- Oldest
SELECT Title, Author, PublicationYear FROM BOOK ORDER BY PublicationYear DESC LIMIT 1; -- Newest

-- 5. Books in the Drama genre
SELECT Title, Author FROM BOOK WHERE Genre = 'Drama';

-- 6. Students registered before 2023 with active loans
SELECT s.FirstName, s.LastName, s.MembershipDate, b.Title, l.LoanDate
FROM LOAN l
JOIN STUDENT s ON l.StudentID = s.StudentID
JOIN BOOK b ON l.Book_ID = b.Book_ID
WHERE s.MembershipDate < '2023-01-01' AND l.ReturnDate IS NULL;

-- 7. Top 5 most borrowed books
SELECT b.Title, COUNT(l.Book_ID) AS LoanFrequency
FROM LOAN l
JOIN BOOK b ON l.Book_ID = b.Book_ID
GROUP BY b.Title
ORDER BY LoanFrequency DESC
LIMIT 5;

-- 8. Librarians handling overdue books
SELECT DISTINCT lb.FirstName, lb.LastName, lb.Email
FROM LOAN l
JOIN LIBRARIAN lb ON l.LibrarianID = lb.LibrarianID
WHERE l.DueDate < CURRENT_DATE AND l.ReturnDate IS NULL;
-- 9. Loans handled by the administrator
SELECT s.FirstName, s.LastName, b.Title, l.LoanDate, l.DueDate
FROM LOAN l
JOIN STUDENT s ON l.StudentID = s.StudentID
JOIN BOOK b ON l.Book_ID = b.Book_ID
JOIN LIBRARIAN lb ON l.LibrarianID = lb.LibrarianID
WHERE lb.EmployeeID = 'ADMIN-001';
