IF DB_ID('Chetverikov_bd') IS NOT NULL
BEGIN
    ALTER DATABASE Chetverikov_bd SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Chetverikov_bd;
END
GO

CREATE DATABASE Chetverikov_bd;
GO

USE Chetverikov_bd;
GO

CREATE TABLE dbo.Groups (
    group_id INT IDENTITY(1,1) PRIMARY KEY,
    group_name VARCHAR(20) NOT NULL UNIQUE,
    specialty VARCHAR(100) NOT NULL,
    admission_year INT NOT NULL CHECK(admission_year > 2000)
);
GO

CREATE TABLE dbo.Teachers (
    teacher_id INT IDENTITY(1,1) PRIMARY KEY,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    department VARCHAR(100) NOT NULL
);
GO

CREATE TABLE dbo.Disciplines (
    discipline_id INT IDENTITY(1,1) PRIMARY KEY,
    discipline_name VARCHAR(100) NOT NULL UNIQUE,
    hours INT NOT NULL CHECK(hours > 0)
);
GO

CREATE TABLE dbo.Students (
    student_id INT IDENTITY(1,1) PRIMARY KEY,
    last_name VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    birth_date DATE NOT NULL,
    group_id INT NOT NULL,
    CONSTRAINT fk_students_groups
        FOREIGN KEY (group_id) REFERENCES dbo.Groups(group_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);
GO

CREATE TABLE dbo.Lessons (
    lesson_id INT IDENTITY(1,1) PRIMARY KEY,
    group_id INT NOT NULL,
    discipline_id INT NOT NULL,
    teacher_id INT NOT NULL,
    lesson_date DATE NOT NULL,
    lesson_type VARCHAR(30) NOT NULL,
    CONSTRAINT fk_lessons_groups
        FOREIGN KEY (group_id) REFERENCES dbo.Groups(group_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_lessons_disciplines
        FOREIGN KEY (discipline_id) REFERENCES dbo.Disciplines(discipline_id)
        ON UPDATE CASCADE ON DELETE NO ACTION,
    CONSTRAINT fk_lessons_teachers
        FOREIGN KEY (teacher_id) REFERENCES dbo.Teachers(teacher_id)
        ON UPDATE CASCADE ON DELETE NO ACTION
);
GO

INSERT INTO dbo.Groups (group_name, specialty, admission_year) VALUES
('П-21', 'Программирование', 2021),
('ИС-22', 'Информационные системы', 2022),
('ЭК-21', 'Экономика', 2021);
GO

INSERT INTO dbo.Students (last_name, first_name, middle_name, birth_date, group_id) VALUES
('Иванов', 'Иван', 'Иванович', '2007-03-15', 1),
('Петров', 'Алексей', 'Сергеевич', '2007-07-21', 1),
('Сидорова', 'Анна', 'Игоревна', '2006-11-04', 2),
('Кузнецов', 'Максим', 'Олегович', '2007-01-18', 2),
('Смирнова', 'Елена', 'Андреевна', '2006-09-27', 3);
GO

INSERT INTO dbo.Teachers (last_name, first_name, department) VALUES
('Волков', 'Александр', 'Информационные технологии'),
('Орлова', 'Мария', 'Общеобразовательные дисциплины'),
('Фёдоров', 'Дмитрий', 'Программирование');
GO

INSERT INTO dbo.Disciplines (discipline_name, hours) VALUES
('Основы проектирования баз данных', 72),
('Информационные технологии', 72),
('Программирование', 144),
('Компьютерные сети', 72);
GO

INSERT INTO dbo.Lessons (group_id, discipline_id, teacher_id, lesson_date, lesson_type) VALUES
(1, 1, 1, '2026-09-10', 'Лекция'),
(1, 3, 3, '2026-09-11', 'Практика'),
(2, 1, 1, '2026-09-10', 'Практика'),
(2, 2, 2, '2026-09-12', 'Лекция'),
(3, 2, 2, '2026-09-13', 'Практика');
GO

SELECT s.student_id, s.last_name + ' ' + s.first_name AS full_name, g.group_name, g.specialty
FROM dbo.Students s JOIN dbo.Groups g ON s.group_id = g.group_id
ORDER BY g.group_name, s.last_name;
GO

SELECT g.group_name, COUNT(s.student_id) AS student_count
FROM dbo.Groups g LEFT JOIN dbo.Students s ON g.group_id = s.group_id
GROUP BY g.group_id, g.group_name
ORDER BY g.group_name;
GO

SELECT l.lesson_date, g.group_name, d.discipline_name,
       t.last_name + ' ' + t.first_name AS teacher_name, l.lesson_type
FROM dbo.Lessons l
JOIN dbo.Groups g ON l.group_id = g.group_id
JOIN dbo.Disciplines d ON l.discipline_id = d.discipline_id
JOIN dbo.Teachers t ON l.teacher_id = t.teacher_id
ORDER BY l.lesson_date;
GO

SELECT discipline_name, hours FROM dbo.Disciplines ORDER BY hours DESC;
GO

INSERT INTO dbo.Students (last_name, first_name, middle_name, birth_date, group_id)
VALUES ('Тестов', 'Тест', 'Тестович', '2000-01-01', 999);
GO

CREATE TABLE dbo.Grades (
    grade_id INT IDENTITY(1,1) PRIMARY KEY,
    student_id INT NOT NULL,
    discipline_id INT NOT NULL,
    grade INT NOT NULL CHECK(grade BETWEEN 2 AND 5),
    grade_date DATE NOT NULL,
    CONSTRAINT fk_grades_students
        FOREIGN KEY (student_id) REFERENCES dbo.Students(student_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_grades_disciplines
        FOREIGN KEY (discipline_id) REFERENCES dbo.Disciplines(discipline_id)
        ON UPDATE CASCADE ON DELETE NO ACTION
);
GO

INSERT INTO dbo.Grades (student_id, discipline_id, grade, grade_date) VALUES
(1, 1, 5, '2026-09-15'), (1, 3, 4, '2026-09-16'),
(2, 1, 3, '2026-09-15'), (2, 3, 5, '2026-09-16'),
(3, 1, 4, '2026-09-17'), (3, 2, 5, '2026-09-18'),
(4, 2, 4, '2026-09-18'), (4, 1, 3, '2026-09-19'),
(1, 2, 5, '2026-09-20'), (2, 2, 4, '2026-09-21');
GO

SELECT * FROM dbo.Grades;
GO

SELECT d.discipline_name, AVG(CAST(g.grade AS FLOAT)) AS average_grade
FROM dbo.Grades g JOIN dbo.Disciplines d ON g.discipline_id = d.discipline_id
GROUP BY d.discipline_name ORDER BY average_grade DESC;
GO

SET IDENTITY_INSERT dbo.Groups ON;
INSERT INTO dbo.Groups (group_id, group_name, specialty, admission_year)
SELECT 10, 'П-21-TEMP', specialty, admission_year FROM dbo.Groups WHERE group_id = 1;
UPDATE dbo.Students SET group_id = 10 WHERE group_id = 1;
DELETE FROM dbo.Groups WHERE group_id = 1;
SET IDENTITY_INSERT dbo.Groups OFF;
GO

SELECT * FROM dbo.Students WHERE group_id = 10;
GO

SET IDENTITY_INSERT dbo.Groups ON;
INSERT INTO dbo.Groups (group_id, group_name, specialty, admission_year)
SELECT 1, 'П-21', specialty, admission_year FROM dbo.Groups WHERE group_id = 10;
UPDATE dbo.Students SET group_id = 1 WHERE group_id = 10;
DELETE FROM dbo.Groups WHERE group_id = 10;
SET IDENTITY_INSERT dbo.Groups OFF;
GO

INSERT INTO dbo.Groups (group_name, specialty, admission_year) VALUES ('ТЕСТ-00', 'Тестовая специальность', 2024);
DECLARE @testGroupId INT = SCOPE_IDENTITY();
INSERT INTO dbo.Students (last_name, first_name, middle_name, birth_date, group_id)
VALUES ('Тестовый', 'Студент', 'Тестович', '2005-01-01', @testGroupId);
GO

SELECT * FROM dbo.Students WHERE last_name = 'Тестовый';
GO

DELETE FROM dbo.Groups WHERE group_name = 'ТЕСТ-00';
GO

SELECT * FROM dbo.Students WHERE last_name = 'Тестовый';
GO