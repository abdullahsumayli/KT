-- Update admin password
-- New password: KTAdmin@2025#Secure
UPDATE users 
SET hashed_password = '$2b$12$vLJJjYyOOm4Wsa.eKP/MPu2RxFizW/8dtbP3YPjf.RkMZ7D1jlkry'
WHERE email = 'admin@kitchentech.sa';
