-- =============================================================================
-- PennyPal – Complete Database Script
-- =============================================================================
-- App:      PennyPal — Student Finance Companion
-- Backend:  Firebase Cloud Firestore (NoSQL document database)
-- Purpose:  This file provides a full relational representation of the
--           Firestore schema: table definitions, reference/seed data, and
--           common operational queries — as required by the SRS.
--
-- Dialect:  Standard SQL-99 / PostgreSQL-compatible
-- Sections:
--   1. Schema  (DROP + CREATE TABLE + indexes)
--   2. Seed    (reference data + sample rows)
--   3. Queries (select, insert, update, delete patterns)
-- =============================================================================


-- =============================================================================
-- SECTION 1 — SCHEMA
-- =============================================================================

-- Drop tables in reverse-dependency order so the script is re-runnable.
DROP TABLE IF EXISTS ai_chat_sessions;
DROP TABLE IF EXISTS book_chapter_takeaways;
DROP TABLE IF EXISTS book_chapters;
DROP TABLE IF EXISTS learning_content;
DROP TABLE IF EXISTS support_queries;
DROP TABLE IF EXISTS feedback;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS savings_goals;
DROP TABLE IF EXISTS budget_category_limits;
DROP TABLE IF EXISTS budgets;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS user_fcm_tokens;
DROP TABLE IF EXISTS user_profiles;
DROP TABLE IF EXISTS users;


-- -----------------------------------------------------------------------------
-- 1.1  users
-- -----------------------------------------------------------------------------
-- Firestore collection: users
-- Created at registration; stores the baseline account record.

CREATE TABLE users (
    id              VARCHAR(128)    PRIMARY KEY,        -- Firebase Auth UID
    email           VARCHAR(255)    NOT NULL UNIQUE,
    full_name       VARCHAR(255),
    phone_number    VARCHAR(30),
    role            VARCHAR(20)     NOT NULL DEFAULT 'student'
                                    CHECK (role IN ('student', 'admin')),
    is_deactivated  BOOLEAN         NOT NULL DEFAULT FALSE,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ
);

CREATE INDEX idx_users_email        ON users (email);
CREATE INDEX idx_users_role         ON users (role);
CREATE INDEX idx_users_created_at   ON users (created_at DESC);


-- -----------------------------------------------------------------------------
-- 1.2  user_profiles
-- -----------------------------------------------------------------------------
-- Firestore collection: userProfiles
-- Extends users with editable profile fields, photo URL, notification prefs,
-- and FCM token.  Kept in sync with the users document by the app.

CREATE TABLE user_profiles (
    user_id                     VARCHAR(128)    PRIMARY KEY
                                                REFERENCES users (id) ON DELETE CASCADE,
    first_name                  VARCHAR(100),
    last_name                   VARCHAR(100),
    full_name                   VARCHAR(255),
    email                       VARCHAR(255),
    phone_number                VARCHAR(30),
    photo_url                   TEXT,
    institution                 VARCHAR(255),
    bio                         TEXT,
    role                        VARCHAR(20)     NOT NULL DEFAULT 'student'
                                                CHECK (role IN ('student', 'admin')),
    is_email_verified           BOOLEAN         NOT NULL DEFAULT FALSE,
    is_deactivated              BOOLEAN         NOT NULL DEFAULT FALSE,
    -- Latest FCM token (full list in user_fcm_tokens)
    fcm_token                   TEXT,
    -- Notification preference flags synced from the device
    notif_transactions_enabled  BOOLEAN         NOT NULL DEFAULT TRUE,
    notif_budgets_enabled       BOOLEAN         NOT NULL DEFAULT TRUE,
    notif_goals_enabled         BOOLEAN         NOT NULL DEFAULT TRUE,
    notif_daily_reminder        BOOLEAN         NOT NULL DEFAULT FALSE,
    notif_reminder_time         VARCHAR(5)      NOT NULL DEFAULT '20:00',   -- HH:MM
    created_at                  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMPTZ
);

CREATE INDEX idx_user_profiles_role         ON user_profiles (role);
CREATE INDEX idx_user_profiles_created_at   ON user_profiles (created_at DESC);


-- -----------------------------------------------------------------------------
-- 1.3  user_fcm_tokens
-- -----------------------------------------------------------------------------
-- Firestore: array field userProfiles.fcmTokens, normalised to its own table.
-- Allows one user to have multiple device tokens (phone + tablet, etc.).

CREATE TABLE user_fcm_tokens (
    id          SERIAL          PRIMARY KEY,
    user_id     VARCHAR(128)    NOT NULL REFERENCES user_profiles (user_id) ON DELETE CASCADE,
    token       TEXT            NOT NULL,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, token)
);

CREATE INDEX idx_fcm_tokens_user_id ON user_fcm_tokens (user_id);


-- -----------------------------------------------------------------------------
-- 1.4  categories
-- -----------------------------------------------------------------------------
-- Firestore collection: categories
-- Admin-managed transaction categories.

CREATE TABLE categories (
    id          VARCHAR(128)    PRIMARY KEY,
    name        VARCHAR(100)    NOT NULL UNIQUE,
    icon_name   VARCHAR(100),
    color_hex   VARCHAR(7),                     -- e.g. '#4CAF50'
    is_active   BOOLEAN         NOT NULL DEFAULT TRUE,
    created_by  VARCHAR(128)    REFERENCES users (id) ON DELETE SET NULL,
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ
);


-- -----------------------------------------------------------------------------
-- 1.5  transactions
-- -----------------------------------------------------------------------------
-- Firestore collection: transactions

CREATE TABLE transactions (
    id                  VARCHAR(128)    PRIMARY KEY,
    user_id             VARCHAR(128)    NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    type                VARCHAR(10)     NOT NULL CHECK (type IN ('income', 'expense')),
    amount              DECIMAL(18, 2)  NOT NULL CHECK (amount > 0),
    category_id         VARCHAR(100)    NOT NULL,   -- soft ref to categories.name
    description         TEXT            NOT NULL DEFAULT '',
    date                TIMESTAMPTZ     NOT NULL,
    payment_mode        VARCHAR(50)     NOT NULL DEFAULT 'Cash',
    receipt_image_url   TEXT,                       -- Firebase Storage download URL
    source              VARCHAR(100),
    sync_status         VARCHAR(20)     NOT NULL DEFAULT 'synced'
                                        CHECK (sync_status IN ('synced', 'pending', 'failed')),
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ
);

CREATE INDEX idx_transactions_user_date     ON transactions (user_id, date DESC);
CREATE INDEX idx_transactions_user_type     ON transactions (user_id, type, date DESC);
CREATE INDEX idx_transactions_user_category ON transactions (user_id, category_id, date DESC);
CREATE INDEX idx_transactions_date          ON transactions (date);
CREATE INDEX idx_transactions_sync_status   ON transactions (sync_status);


-- -----------------------------------------------------------------------------
-- 1.6  budgets
-- -----------------------------------------------------------------------------
-- Firestore collection: budgets
-- One document per user per calendar month.

CREATE TABLE budgets (
    id              VARCHAR(128)    PRIMARY KEY,
    user_id         VARCHAR(128)    NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    month           CHAR(7)         NOT NULL,       -- 'YYYY-MM' e.g. '2025-09'
    limit_amount    DECIMAL(18, 2)  NOT NULL CHECK (limit_amount > 0),
    alert_threshold DECIMAL(5, 4)   NOT NULL DEFAULT 0.8000
                                    CHECK (alert_threshold BETWEEN 0 AND 1),
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ,
    UNIQUE (user_id, month)
);

CREATE INDEX idx_budgets_user_month ON budgets (user_id, month DESC);


-- -----------------------------------------------------------------------------
-- 1.7  budget_category_limits
-- -----------------------------------------------------------------------------
-- Firestore: nested map budgets.categoryLimits, normalised to rows.

CREATE TABLE budget_category_limits (
    id              SERIAL          PRIMARY KEY,
    budget_id       VARCHAR(128)    NOT NULL REFERENCES budgets (id) ON DELETE CASCADE,
    category        VARCHAR(100)    NOT NULL,
    limit_amount    DECIMAL(18, 2)  NOT NULL CHECK (limit_amount >= 0),
    UNIQUE (budget_id, category)
);

CREATE INDEX idx_budget_cat_limits_budget_id ON budget_category_limits (budget_id);


-- -----------------------------------------------------------------------------
-- 1.8  savings_goals
-- -----------------------------------------------------------------------------
-- Firestore collection: savingsGoals

CREATE TABLE savings_goals (
    id                      VARCHAR(128)    PRIMARY KEY,
    user_id                 VARCHAR(128)    NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    goal_name               VARCHAR(255)    NOT NULL,
    target_amount           DECIMAL(18, 2)  NOT NULL CHECK (target_amount > 0),
    current_amount          DECIMAL(18, 2)  NOT NULL DEFAULT 0.00 CHECK (current_amount >= 0),
    monthly_contribution    DECIMAL(18, 2)  NOT NULL DEFAULT 0.00 CHECK (monthly_contribution >= 0),
    target_date             DATE            NOT NULL,
    status                  VARCHAR(20)     NOT NULL DEFAULT 'active'
                                            CHECK (status IN ('active', 'completed', 'paused', 'cancelled')),
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ
);

CREATE INDEX idx_goals_user_status      ON savings_goals (user_id, status);
CREATE INDEX idx_goals_user_target_date ON savings_goals (user_id, target_date ASC);


-- -----------------------------------------------------------------------------
-- 1.9  notifications
-- -----------------------------------------------------------------------------
-- Firestore collection: notifications

CREATE TABLE notifications (
    id          VARCHAR(128)    PRIMARY KEY,
    user_id     VARCHAR(128)    NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    title       VARCHAR(255)    NOT NULL,
    body        TEXT            NOT NULL,
    type        VARCHAR(50)     NOT NULL,   -- 'transaction' | 'budget' | 'goal' | 'system'
    is_read     BOOLEAN         NOT NULL DEFAULT FALSE,
    route       VARCHAR(255),               -- deep-link on tap, e.g. '/notifications'
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_created ON notifications (user_id, created_at DESC);
CREATE INDEX idx_notifications_user_read    ON notifications (user_id, is_read);


-- -----------------------------------------------------------------------------
-- 1.10  feedback
-- -----------------------------------------------------------------------------
-- Firestore collection: feedback

CREATE TABLE feedback (
    id          VARCHAR(128)    PRIMARY KEY,
    user_id     VARCHAR(128)    NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    subject     VARCHAR(255),
    message     TEXT            NOT NULL,
    rating      SMALLINT        CHECK (rating BETWEEN 1 AND 5),
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_feedback_user_created ON feedback (user_id, created_at DESC);


-- -----------------------------------------------------------------------------
-- 1.11  support_queries
-- -----------------------------------------------------------------------------
-- Firestore collection: supportQueries

CREATE TABLE support_queries (
    id          VARCHAR(128)    PRIMARY KEY,
    user_id     VARCHAR(128)    NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    subject     VARCHAR(255),
    message     TEXT            NOT NULL,
    status      VARCHAR(20)     NOT NULL DEFAULT 'open'
                                CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ
);

CREATE INDEX idx_support_user_created   ON support_queries (user_id, created_at DESC);
CREATE INDEX idx_support_status_created ON support_queries (status, created_at ASC);


-- -----------------------------------------------------------------------------
-- 1.12  learning_content
-- -----------------------------------------------------------------------------
-- Firestore collection: learningContent

CREATE TABLE learning_content (
    id                  VARCHAR(128)    PRIMARY KEY,
    title               VARCHAR(255)    NOT NULL,
    subtitle            VARCHAR(255),
    category            VARCHAR(100)    NOT NULL,
    level               VARCHAR(20)     NOT NULL DEFAULT 'Beginner'
                                        CHECK (level IN ('Beginner', 'Intermediate', 'Advanced')),
    read_time_minutes   SMALLINT        NOT NULL DEFAULT 5,
    chapter_count       SMALLINT        NOT NULL DEFAULT 1,
    icon_name           VARCHAR(100),
    author              VARCHAR(255)    NOT NULL DEFAULT 'PennyPal Financial Academy',
    summary             TEXT,
    is_published        BOOLEAN         NOT NULL DEFAULT TRUE,
    created_by          VARCHAR(128)    REFERENCES users (id) ON DELETE SET NULL,
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ
);

CREATE INDEX idx_learning_published_created ON learning_content (is_published, created_at DESC);


-- -----------------------------------------------------------------------------
-- 1.13  book_chapters
-- -----------------------------------------------------------------------------

CREATE TABLE book_chapters (
    id              SERIAL          PRIMARY KEY,
    book_id         VARCHAR(128)    NOT NULL REFERENCES learning_content (id) ON DELETE CASCADE,
    chapter_number  VARCHAR(10)     NOT NULL,
    title           VARCHAR(255)    NOT NULL,
    read_time       VARCHAR(30),
    summary         TEXT,
    content         TEXT,
    sort_order      SMALLINT        NOT NULL DEFAULT 0,
    UNIQUE (book_id, chapter_number)
);

CREATE INDEX idx_chapters_book_id ON book_chapters (book_id, sort_order);


-- -----------------------------------------------------------------------------
-- 1.14  book_chapter_takeaways
-- -----------------------------------------------------------------------------
-- Normalised form of the takeaways string array on BookChapter.

CREATE TABLE book_chapter_takeaways (
    id          SERIAL      PRIMARY KEY,
    chapter_id  INTEGER     NOT NULL REFERENCES book_chapters (id) ON DELETE CASCADE,
    takeaway    TEXT        NOT NULL,
    sort_order  SMALLINT    NOT NULL DEFAULT 0
);

CREATE INDEX idx_takeaways_chapter_id ON book_chapter_takeaways (chapter_id, sort_order);


-- -----------------------------------------------------------------------------
-- 1.15  ai_chat_sessions
-- -----------------------------------------------------------------------------
-- Not persisted to Firestore in the current release (in-memory only).
-- Schema provided for a future persistence layer.

CREATE TABLE ai_chat_sessions (
    id          SERIAL          PRIMARY KEY,
    user_id     VARCHAR(128)    NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    role        VARCHAR(20)     NOT NULL CHECK (role IN ('system', 'user', 'assistant')),
    content     TEXT            NOT NULL,
    model       VARCHAR(100),
    created_at  TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ai_sessions_user_created ON ai_chat_sessions (user_id, created_at ASC);


-- =============================================================================
-- SECTION 2 — SEED DATA
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 2.1  Default categories
-- -----------------------------------------------------------------------------

INSERT INTO categories (id, name, icon_name, color_hex, is_active) VALUES
    ('cat_food',          'Food & Drinks',    'food',          '#FF6B6B', TRUE),
    ('cat_transport',     'Transport',        'transport',     '#4ECDC4', TRUE),
    ('cat_accommodation', 'Accommodation',    'home',          '#45B7D1', TRUE),
    ('cat_education',     'Education',        'book',          '#96CEB4', TRUE),
    ('cat_health',        'Health',           'health',        '#FFEAA7', TRUE),
    ('cat_shopping',      'Shopping',         'shopping',      '#DDA0DD', TRUE),
    ('cat_entertainment', 'Entertainment',    'entertainment', '#98D8C8', TRUE),
    ('cat_data',          'Data & Airtime',   'phone',         '#F7DC6F', TRUE),
    ('cat_savings',       'Savings',          'piggy',         '#82E0AA', TRUE),
    ('cat_income_salary', 'Salary / Stipend', 'money',         '#58D68D', TRUE),
    ('cat_income_gift',   'Gift / Allowance', 'gift',          '#5DADE2', TRUE),
    ('cat_income_hustle', 'Side Hustle',      'trending_up',   '#A569BD', TRUE),
    ('cat_misc',          'Miscellaneous',    'misc',          '#AAB7B8', TRUE);


-- -----------------------------------------------------------------------------
-- 2.2  Demo users  (passwords are managed by Firebase Auth, not stored here)
-- -----------------------------------------------------------------------------

INSERT INTO users (id, email, full_name, phone_number, role, is_deactivated, created_at) VALUES
    ('uid_student_01', 'amaka.obi@student.unilag.edu.ng', 'Amaka Obi',      '08012345678', 'student', FALSE, '2025-09-01 08:00:00+01'),
    ('uid_student_02', 'chidi.eze@student.unilag.edu.ng', 'Chidi Eze',      '08023456789', 'student', FALSE, '2025-09-02 09:30:00+01'),
    ('uid_admin_01',   'admin@pennypal.app',               'PennyPal Admin', NULL,          'admin',   FALSE, '2025-08-15 10:00:00+01');

INSERT INTO user_profiles (
    user_id, first_name, last_name, full_name, email, phone_number,
    role, is_email_verified, is_deactivated,
    notif_transactions_enabled, notif_budgets_enabled, notif_goals_enabled,
    notif_daily_reminder, notif_reminder_time, created_at
) VALUES
    ('uid_student_01', 'Amaka',    'Obi',   'Amaka Obi',      'amaka.obi@student.unilag.edu.ng', '08012345678', 'student', TRUE, FALSE, TRUE, TRUE, TRUE, TRUE,  '20:00', '2025-09-01 08:00:00+01'),
    ('uid_student_02', 'Chidi',    'Eze',   'Chidi Eze',      'chidi.eze@student.unilag.edu.ng', '08023456789', 'student', TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, '20:00', '2025-09-02 09:30:00+01'),
    ('uid_admin_01',   'PennyPal', 'Admin', 'PennyPal Admin', 'admin@pennypal.app',               NULL,          'admin',   TRUE, FALSE, TRUE, TRUE, TRUE, FALSE, '20:00', '2025-08-15 10:00:00+01');


-- -----------------------------------------------------------------------------
-- 2.3  Sample transactions (September 2025)
-- -----------------------------------------------------------------------------

INSERT INTO transactions (id, user_id, type, amount, category_id, description, date, payment_mode, sync_status) VALUES
    ('tx_01', 'uid_student_01', 'income',  50000.00, 'cat_income_gift',   'September pocket money',     '2025-09-01 09:00:00+01', 'Bank Transfer', 'synced'),
    ('tx_02', 'uid_student_01', 'income',  15000.00, 'cat_income_hustle', 'Graphic design gig payment', '2025-09-10 14:00:00+01', 'Bank Transfer', 'synced'),
    ('tx_03', 'uid_student_01', 'expense',  8500.00, 'cat_food',          'Monthly bulk groceries',     '2025-09-01 12:00:00+01', 'Cash',          'synced'),
    ('tx_04', 'uid_student_01', 'expense',  3200.00, 'cat_transport',     'Bolt rides (weekly)',        '2025-09-07 19:00:00+01', 'Cash',          'synced'),
    ('tx_05', 'uid_student_01', 'expense',   500.00, 'cat_data',          '1GB MTN data',               '2025-09-08 11:00:00+01', 'USSD',          'synced'),
    ('tx_06', 'uid_student_01', 'expense',  1200.00, 'cat_entertainment', 'Cinema with friends',        '2025-09-14 18:30:00+01', 'POS',           'synced'),
    ('tx_07', 'uid_student_01', 'expense',  2500.00, 'cat_education',     'Course textbook',            '2025-09-15 10:00:00+01', 'Bank Transfer', 'synced'),
    ('tx_08', 'uid_student_02', 'income',  40000.00, 'cat_income_salary', 'Monthly allowance',          '2025-09-01 08:00:00+01', 'Bank Transfer', 'synced'),
    ('tx_09', 'uid_student_02', 'expense',  6000.00, 'cat_food',          'Cafeteria meals',            '2025-09-03 13:00:00+01', 'Cash',          'synced'),
    ('tx_10', 'uid_student_02', 'expense',  1500.00, 'cat_health',        'Paracetamol & rehydration',  '2025-09-12 16:00:00+01', 'Cash',          'synced');


-- -----------------------------------------------------------------------------
-- 2.4  Sample budgets
-- -----------------------------------------------------------------------------

INSERT INTO budgets (id, user_id, month, limit_amount, alert_threshold, created_at) VALUES
    ('bgt_01', 'uid_student_01', '2025-09', 40000.00, 0.80, '2025-09-01 09:10:00+01'),
    ('bgt_02', 'uid_student_02', '2025-09', 35000.00, 0.85, '2025-09-01 08:10:00+01');

INSERT INTO budget_category_limits (budget_id, category, limit_amount) VALUES
    ('bgt_01', 'Food & Drinks',  10000.00),
    ('bgt_01', 'Transport',       4000.00),
    ('bgt_01', 'Data & Airtime',  2000.00),
    ('bgt_01', 'Entertainment',   3000.00),
    ('bgt_02', 'Food & Drinks',   8000.00),
    ('bgt_02', 'Transport',       3000.00),
    ('bgt_02', 'Health',          2000.00);


-- -----------------------------------------------------------------------------
-- 2.5  Sample savings goals
-- -----------------------------------------------------------------------------

INSERT INTO savings_goals (id, user_id, goal_name, target_amount, current_amount, monthly_contribution, target_date, status, created_at) VALUES
    ('goal_01', 'uid_student_01', 'New Laptop',     150000.00, 35000.00, 10000.00, '2026-06-30', 'active', '2025-09-01 09:15:00+01'),
    ('goal_02', 'uid_student_01', 'Emergency Vault',105000.00, 20000.00,  5000.00, '2026-03-31', 'active', '2025-09-01 09:20:00+01'),
    ('goal_03', 'uid_student_02', 'ICAN Exam Fees',  75000.00, 10000.00,  7500.00, '2026-01-31', 'active', '2025-09-02 09:05:00+01');


-- -----------------------------------------------------------------------------
-- 2.6  Sample notifications
-- -----------------------------------------------------------------------------

INSERT INTO notifications (id, user_id, title, body, type, is_read, route, created_at) VALUES
    ('notif_01', 'uid_student_01', 'Budget Alert',      'You have used 80% of your Food & Drinks budget for September.',  'budget',      FALSE, '/home',  '2025-09-18 10:00:00+01'),
    ('notif_02', 'uid_student_01', 'Goal Update',       'Great work! You are 23% of the way to your New Laptop goal.',    'goal',        TRUE,  '/goals', '2025-09-10 09:00:00+01'),
    ('notif_03', 'uid_student_02', 'Transaction Added', 'Expense of ₦6,000 recorded under Food & Drinks.',               'transaction', TRUE,  '/home',  '2025-09-03 13:01:00+01');


-- -----------------------------------------------------------------------------
-- 2.7  Sample feedback and support queries
-- -----------------------------------------------------------------------------

INSERT INTO feedback (id, user_id, subject, message, rating, created_at) VALUES
    ('fb_01', 'uid_student_01', 'Love the app',    'PennyPal has completely changed how I manage my allowance. The AI assistant is surprisingly helpful!', 5, '2025-09-20 15:00:00+01'),
    ('fb_02', 'uid_student_02', 'Feature request', 'Would be great to see a dark-mode chart theme and a home screen widget.',                              4, '2025-09-21 11:30:00+01');

INSERT INTO support_queries (id, user_id, subject, message, status, created_at) VALUES
    ('sq_01', 'uid_student_01', 'Receipt photo not uploading', 'Upload spinner keeps running despite a stable connection.', 'open', '2025-09-22 14:00:00+01');


-- -----------------------------------------------------------------------------
-- 2.8  Built-in learning content (mirrors learning_materials.dart)
-- -----------------------------------------------------------------------------

INSERT INTO learning_content (id, title, subtitle, category, level, read_time_minutes, chapter_count, icon_name, author, summary, is_published, created_at) VALUES
    ('campus-money-playbook',     'The Campus Money Playbook',      'From Broke Student to Financially Fearless',        'Budgeting & Habits', 'Beginner',     12, 4, 'book',        'PennyPal Financial Academy', 'The definitive student playbook for mastering monthly allowances, eliminating unmonitored account leaks, and budgeting for Nigerian campus life.',                                                             TRUE, '2025-08-15 10:00:00+01'),
    ('emergency-vault-guide',     'Emergency Vault: Sapa Defense',  'Building a Bulletproof Safety Net Against Sapa',    'Savings & Defense',  'Intermediate', 14, 4, 'shield',      'PennyPal Financial Academy', 'A tactical guide to calculating your minimum survival numbers, isolating emergency funds from daily temptations, and staying solvent during price shocks.',                                               TRUE, '2025-08-15 10:05:00+01'),
    ('student-wealth-starter-kit','Digital Hustles & First Investments','The Student Wealth Starter Kit',                'Income & Growth',    'Advanced',     16, 4, 'trending_up', 'PennyPal Financial Academy', 'A masterclass on monetizing high-value digital skills on campus, understanding compound interest, and avoiding fraudulent get-rich-quick traps.',                                                          TRUE, '2025-08-15 10:10:00+01');

INSERT INTO book_chapters (book_id, chapter_number, title, read_time, summary, sort_order) VALUES
    ('campus-money-playbook', '01', 'The Harsh Truth About Student Pocket Money', '3 min read', 'Why monthly allowances disappear in the first 10 days and how to stop accidental account leaks.',         1),
    ('campus-money-playbook', '02', 'The 50/30/20 Rule for Nigerian Campuses',    '3 min read', 'Customizing the famous budgeting framework to real Nigerian student realities.',                          2),
    ('campus-money-playbook', '03', 'The ₦500 Daily Micro-Savings Rule',          '3 min read', 'How small, painless daily amounts compound into serious financial safety.',                               3),
    ('campus-money-playbook', '04', 'The 48-Hour Impulsive Purchase Shield',      '3 min read', 'Defeating online shopping traps, flash sales, and peer pressure spending.',                              4),
    ('emergency-vault-guide', '01', 'Calculating Your True Survival Baseline',    '3 min read', 'Finding out how much you actually need to survive for 30 days if all income stops.',                     1),
    ('emergency-vault-guide', '02', 'Where to Store Your Emergency Funds',        '3 min read', 'Why your regular daily bank card account is the worst place for emergency savings.',                     2),
    ('emergency-vault-guide', '03', 'What Counts as a True Emergency?',           '4 min read', 'The 3-question filter to determine if you should touch your emergency reserve.',                         3),
    ('emergency-vault-guide', '04', 'Rebuilding Your Safety Net After a Crisis',  '4 min read', 'The step-by-step recovery plan after an unexpected expense drains your reserves.',                       4),
    ('student-wealth-starter-kit', '01', 'High-Income Skills You Can Learn on Campus',        '4 min read', 'Monetizing digital competencies alongside your university degree.',                          1),
    ('student-wealth-starter-kit', '02', 'The Unstoppable Magic of Compound Interest',        '4 min read', 'Why starting to invest ₦5,000 at age 20 destroys ₦50,000 at age 35.',                       2),
    ('student-wealth-starter-kit', '03', 'Spotting Ponzi Schemes & Fast-Money Traps',         '4 min read', 'Recognizing fraudulent investment traps before they wipe out your student savings.',         3),
    ('student-wealth-starter-kit', '04', 'Designing Your 5-Year Financial Freedom Blueprint', '4 min read', 'Crafting a clear trajectory from university graduation to early career financial security.',  4);


-- =============================================================================
-- SECTION 3 — QUERIES
-- =============================================================================
-- SQL equivalents of the Firestore queries used throughout the app.
-- Replace :uid, :month, :start_date etc. with actual parameter values.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Q1.  All transactions for a user, newest first
-- -----------------------------------------------------------------------------
-- Firestore: transactions.where('userId', ==, uid).orderBy('date', desc)

SELECT id, type, amount, category_id, description, date, payment_mode,
       receipt_image_url, sync_status
FROM   transactions
WHERE  user_id = :uid
ORDER  BY date DESC;


-- -----------------------------------------------------------------------------
-- Q2.  Monthly income vs expense totals
-- -----------------------------------------------------------------------------

SELECT type, SUM(amount) AS total
FROM   transactions
WHERE  user_id = :uid
  AND  date >= DATE_TRUNC('month', CURRENT_DATE)
  AND  date <  DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
GROUP  BY type;


-- -----------------------------------------------------------------------------
-- Q3.  Per-category spending this month  (budget tracking)
-- -----------------------------------------------------------------------------

SELECT category_id, SUM(amount) AS spent
FROM   transactions
WHERE  user_id = :uid
  AND  type    = 'expense'
  AND  date >= DATE_TRUNC('month', CURRENT_DATE)
  AND  date <  DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
GROUP  BY category_id
ORDER  BY spent DESC;


-- -----------------------------------------------------------------------------
-- Q4.  Budget with category limits for a given month
-- -----------------------------------------------------------------------------
-- Firestore: budgets.where('userId', ==, uid)

SELECT b.id, b.month, b.limit_amount, b.alert_threshold,
       bcl.category, bcl.limit_amount AS category_limit
FROM   budgets b
LEFT   JOIN budget_category_limits bcl ON bcl.budget_id = b.id
WHERE  b.user_id = :uid
  AND  b.month   = :month
ORDER  BY bcl.category;


-- -----------------------------------------------------------------------------
-- Q5.  All savings goals for a user
-- -----------------------------------------------------------------------------
-- Firestore: savingsGoals.where('userId', ==, uid)

SELECT id, goal_name, target_amount, current_amount,
       ROUND(current_amount / NULLIF(target_amount, 0), 4) AS progress,
       monthly_contribution, target_date, status
FROM   savings_goals
WHERE  user_id = :uid
ORDER  BY CASE status WHEN 'active' THEN 0 ELSE 1 END, target_date ASC;


-- -----------------------------------------------------------------------------
-- Q6.  Notification inbox, newest first
-- -----------------------------------------------------------------------------
-- Firestore: notifications.where('userId', ==, uid).orderBy('createdAt', desc)

SELECT id, title, body, type, is_read, route, created_at
FROM   notifications
WHERE  user_id = :uid
ORDER  BY created_at DESC;


-- -----------------------------------------------------------------------------
-- Q7.  Mark a notification as read
-- -----------------------------------------------------------------------------

UPDATE notifications
SET    is_read = TRUE
WHERE  id = :notification_id AND user_id = :uid;


-- -----------------------------------------------------------------------------
-- Q8.  Daily spending for the last 14 days  (sparkline chart)
-- -----------------------------------------------------------------------------

SELECT DATE(date) AS day, SUM(amount) AS total_spent
FROM   transactions
WHERE  user_id = :uid
  AND  type    = 'expense'
  AND  date   >= CURRENT_DATE - INTERVAL '13 days'
GROUP  BY DATE(date)
ORDER  BY day ASC;


-- -----------------------------------------------------------------------------
-- Q9.  Monthly net balance over the last 6 months  (reports screen)
-- -----------------------------------------------------------------------------

SELECT TO_CHAR(DATE_TRUNC('month', date), 'YYYY-MM')            AS month,
       SUM(CASE WHEN type = 'income'  THEN amount ELSE 0 END)   AS income,
       SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END)   AS expenses,
       SUM(CASE WHEN type = 'income'  THEN amount ELSE -amount END) AS net
FROM   transactions
WHERE  user_id = :uid
  AND  date   >= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '5 months'
GROUP  BY DATE_TRUNC('month', date)
ORDER  BY month ASC;


-- -----------------------------------------------------------------------------
-- Q10. Admin — new student signups in date range  (analytics chart)
-- -----------------------------------------------------------------------------
-- Firestore: userProfiles.where('createdAt', >=, cutoff)

SELECT DATE(created_at) AS day, COUNT(*) AS signups
FROM   user_profiles
WHERE  role       = 'student'
  AND  created_at >= :start_date
GROUP  BY DATE(created_at)
ORDER  BY day ASC;


-- -----------------------------------------------------------------------------
-- Q11. Admin — transaction volume by day  (analytics chart)
-- -----------------------------------------------------------------------------

SELECT DATE(date) AS day, COUNT(*) AS count, SUM(amount) AS volume
FROM   transactions
WHERE  date >= :start_date
GROUP  BY DATE(date)
ORDER  BY day ASC;


-- -----------------------------------------------------------------------------
-- Q12. Admin — student list, newest registrations first
-- -----------------------------------------------------------------------------

SELECT user_id, full_name, email, institution, is_email_verified,
       is_deactivated, created_at
FROM   user_profiles
WHERE  role = 'student'
ORDER  BY created_at DESC;


-- -----------------------------------------------------------------------------
-- Q13. Admin — open support ticket queue, oldest first
-- -----------------------------------------------------------------------------

SELECT sq.id, sq.user_id, up.full_name, sq.subject, sq.message,
       sq.status, sq.created_at
FROM   support_queries sq
JOIN   user_profiles up ON up.user_id = sq.user_id
WHERE  sq.status = 'open'
ORDER  BY sq.created_at ASC;


-- -----------------------------------------------------------------------------
-- Q14. Admin — published learning content list
-- -----------------------------------------------------------------------------

SELECT id, title, subtitle, category, level, read_time_minutes,
       chapter_count, author, is_published, created_at
FROM   learning_content
ORDER  BY created_at DESC;


-- -----------------------------------------------------------------------------
-- Q15. Upsert a transaction  (saveTransaction)
-- -----------------------------------------------------------------------------

INSERT INTO transactions (
    id, user_id, type, amount, category_id,
    description, date, payment_mode, receipt_image_url, source, sync_status, created_at
) VALUES (
    :id, :user_id, :type, :amount, :category_id,
    :description, :date, :payment_mode, :receipt_image_url, :source, 'synced', NOW()
)
ON CONFLICT (id) DO UPDATE SET
    amount            = EXCLUDED.amount,
    category_id       = EXCLUDED.category_id,
    description       = EXCLUDED.description,
    date              = EXCLUDED.date,
    payment_mode      = EXCLUDED.payment_mode,
    receipt_image_url = EXCLUDED.receipt_image_url,
    source            = EXCLUDED.source,
    sync_status       = EXCLUDED.sync_status,
    updated_at        = NOW();


-- -----------------------------------------------------------------------------
-- Q16. Upsert a budget  (saveBudget)
-- -----------------------------------------------------------------------------

INSERT INTO budgets (id, user_id, month, limit_amount, alert_threshold, created_at)
VALUES (:id, :user_id, :month, :limit_amount, :alert_threshold, NOW())
ON CONFLICT (id) DO UPDATE SET
    limit_amount    = EXCLUDED.limit_amount,
    alert_threshold = EXCLUDED.alert_threshold,
    updated_at      = NOW();


-- -----------------------------------------------------------------------------
-- Q17. Upsert a savings goal  (saveGoal)
-- -----------------------------------------------------------------------------

INSERT INTO savings_goals (
    id, user_id, goal_name, target_amount, current_amount,
    monthly_contribution, target_date, status, created_at
) VALUES (
    :id, :user_id, :goal_name, :target_amount, :current_amount,
    :monthly_contribution, :target_date, :status, NOW()
)
ON CONFLICT (id) DO UPDATE SET
    goal_name            = EXCLUDED.goal_name,
    target_amount        = EXCLUDED.target_amount,
    current_amount       = EXCLUDED.current_amount,
    monthly_contribution = EXCLUDED.monthly_contribution,
    target_date          = EXCLUDED.target_date,
    status               = EXCLUDED.status,
    updated_at           = NOW();


-- -----------------------------------------------------------------------------
-- Q18. Delete a transaction / budget / goal
-- -----------------------------------------------------------------------------

DELETE FROM transactions WHERE id = :id AND user_id = :uid;
DELETE FROM budgets       WHERE id = :id AND user_id = :uid;
DELETE FROM savings_goals WHERE id = :id AND user_id = :uid;


-- -----------------------------------------------------------------------------
-- Q19. Submit feedback
-- -----------------------------------------------------------------------------

INSERT INTO feedback (id, user_id, subject, message, rating, created_at)
VALUES (:id, :user_id, :subject, :message, :rating, NOW());


-- -----------------------------------------------------------------------------
-- Q20. Submit support query
-- -----------------------------------------------------------------------------

INSERT INTO support_queries (id, user_id, subject, message, status, created_at)
VALUES (:id, :user_id, :subject, :message, 'open', NOW());


-- -----------------------------------------------------------------------------
-- Q21. Push an in-app notification  (addNotification)
-- -----------------------------------------------------------------------------

INSERT INTO notifications (id, user_id, title, body, type, is_read, route, created_at)
VALUES (:id, :user_id, :title, :body, :type, FALSE, :route, NOW());


-- -----------------------------------------------------------------------------
-- Q22. Deactivate a user account
-- -----------------------------------------------------------------------------

UPDATE users         SET is_deactivated = TRUE, updated_at = NOW() WHERE id = :uid;
UPDATE user_profiles SET is_deactivated = TRUE, updated_at = NOW() WHERE user_id = :uid;


-- -----------------------------------------------------------------------------
-- Q23. Sync notification preferences  (NotificationService.syncPreferences)
-- -----------------------------------------------------------------------------

UPDATE user_profiles
SET    notif_transactions_enabled = :transactions,
       notif_budgets_enabled      = :budgets,
       notif_goals_enabled        = :goals,
       notif_daily_reminder       = :reminder,
       notif_reminder_time        = :reminder_time,
       updated_at                 = NOW()
WHERE  user_id = :uid;
