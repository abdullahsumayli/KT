-- Create admin user with pre-hashed password
-- Password: Admin@2025
-- Hash: $2b$12$ub4MLu5Gl7gso.mp7/71KeFCsTS99xyM8UXGq1m1.4Le4CDvyx4Q6

INSERT INTO users (
    email,
    username,
    hashed_password,
    full_name,
    role,
    status,
    is_active,
    is_verified,
    created_at
) VALUES (
    'admin@kitchentech.sa',
    'admin',
    '$2b$12$ub4MLu5Gl7gso.mp7/71KeFCsTS99xyM8UXGq1m1.4Le4CDvyx4Q6',
    'مدير النظام',
    'ADMIN',
    'ACTIVE',
    true,
    true,
    NOW()
) ON CONFLICT DO NOTHING;
