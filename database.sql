-- إنشاء قاعدة البيانات
CREATE DATABASE IF NOT EXISTS surveylink_db;
USE surveylink_db;

-- جدول المستخدمين
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  location VARCHAR(255),
  bio TEXT,
  avatar VARCHAR(255),
  role ENUM('surveyor', 'company', 'admin') NOT NULL,
  verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- جدول معلومات المساحين
CREATE TABLE IF NOT EXISTS surveyors (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  experience INT,
  education VARCHAR(255),
  skills TEXT,
  certificates TEXT,
  rating DECIMAL(3,2) DEFAULT 0,
  projects_completed INT DEFAULT 0,
  clients_count INT DEFAULT 0,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- جدول معلومات الشركات
CREATE TABLE IF NOT EXISTS companies (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  company_type VARCHAR(100),
  founded_year INT,
  employees_count INT,
  website VARCHAR(255),
  services TEXT,
  rating DECIMAL(3,2) DEFAULT 0,
  projects_completed INT DEFAULT 0,
  clients_count INT DEFAULT 0,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- جدول المشاريع
CREATE TABLE IF NOT EXISTS projects (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  company_id INT,
  location VARCHAR(255),
  image VARCHAR(255),
  start_date DATE,
  end_date DATE,
  project_type ENUM('road', 'construction', 'infrastructure', 'GIS', 'other'),
  area DECIMAL(10,2),
  team TEXT,
  progress INT DEFAULT 0,
  budget DECIMAL(12,2),
  status ENUM('planning', 'in-progress', 'completed') DEFAULT 'planning',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (company_id) REFERENCES companies(id)
);

-- جدول الوظائف
CREATE TABLE IF NOT EXISTS jobs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  company_id INT,
  location VARCHAR(255),
  job_type ENUM('full-time', 'part-time', 'contract', 'remote'),
  experience VARCHAR(50),
  salary_min DECIMAL(10,2),
  salary_max DECIMAL(10,2),
  requirements TEXT,
  tags VARCHAR(255),
  status ENUM('open', 'closed', 'filled') DEFAULT 'open',
  posted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expires_at DATE,
  FOREIGN KEY (company_id) REFERENCES companies(id)
);

-- جدول المزادات
CREATE TABLE IF NOT EXISTS auctions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  project_owner_id INT NOT NULL,
  location VARCHAR(255),
  area DECIMAL(10,2),
  duration INT,
  budget_min DECIMAL(12,2),
  budget_max DECIMAL(12,2),
  requirements TEXT,
  status ENUM('open', 'ended', 'awarded') DEFAULT 'open',
  start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  end_date TIMESTAMP,
  views_count INT DEFAULT 0,
  FOREIGN KEY (project_owner_id) REFERENCES users(id)
);

-- جدول عروض المزادات
CREATE TABLE IF NOT EXISTS auction_bids (
  id INT AUTO_INCREMENT PRIMARY KEY,
  auction_id INT NOT NULL,
  surveyor_id INT NOT NULL,
  bid_amount DECIMAL(12,2) NOT NULL,
  proposal TEXT,
  estimated_duration INT,
  status ENUM('pending', 'accepted', 'rejected') DEFAULT 'pending',
  bid_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (auction_id) REFERENCES auctions(id),
  FOREIGN KEY (surveyor_id) REFERENCES surveyors(id)
);

-- جدول المنشورات المجتمعية
CREATE TABLE IF NOT EXISTS posts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  content TEXT NOT NULL,
  image VARCHAR(255),
  likes INT DEFAULT 0,
  comments INT DEFAULT 0,
  shares INT DEFAULT 0,
  tags TEXT,
  posted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- جدول التعليقات
CREATE TABLE IF NOT EXISTS comments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  post_id INT NOT NULL,
  user_id INT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- جدول الإعجابات
CREATE TABLE IF NOT EXISTS likes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  post_id INT NOT NULL,
  user_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id),
  UNIQUE KEY unique_like (post_id, user_id)
);

-- جدول التقييمات
CREATE TABLE IF NOT EXISTS ratings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  rated_user_id INT NOT NULL,
  rater_user_id INT NOT NULL,
  project_id INT,
  rating DECIMAL(3,2) NOT NULL,
  review TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (rated_user_id) REFERENCES users(id),
  FOREIGN KEY (rater_user_id) REFERENCES users(id),
  FOREIGN KEY (project_id) REFERENCES projects(id)
);

-- جدول الشهادات
CREATE TABLE IF NOT EXISTS certificates (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  issuing_organization VARCHAR(255),
  issue_date DATE,
  expiry_date DATE,
  credential_id VARCHAR(100),
  credential_url VARCHAR(255),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- جدول الخبرات
CREATE TABLE IF NOT EXISTS experiences (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  company VARCHAR(255),
  location VARCHAR(255),
  from_date DATE,
  to_date DATE,
  is_current BOOLEAN DEFAULT false,
  description TEXT,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- جدول المهارات
CREATE TABLE IF NOT EXISTS skills (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  category VARCHAR(100)
);

-- جدول مهارات المستخدمين
CREATE TABLE IF NOT EXISTS user_skills (
  user_id INT NOT NULL,
  skill_id INT NOT NULL,
  proficiency ENUM('beginner', 'intermediate', 'advanced', 'expert') DEFAULT 'intermediate',
  PRIMARY KEY (user_id, skill_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (skill_id) REFERENCES skills(id)
);

-- جدول التطبيقات على الوظائف
CREATE TABLE IF NOT EXISTS job_applications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  job_id INT NOT NULL,
  applicant_id INT NOT NULL,
  resume VARCHAR(255),
  cover_letter TEXT,
  status ENUM('pending', 'reviewed', 'interviewed', 'accepted', 'rejected') DEFAULT 'pending',
  applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (job_id) REFERENCES jobs(id),
  FOREIGN KEY (applicant_id) REFERENCES users(id)
);

-- جدول الإشعارات
CREATE TABLE IF NOT EXISTS notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  content TEXT,
  type VARCHAR(50),
  reference_id INT,
  reference_type VARCHAR(50),
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- جدول الرسائل
CREATE TABLE IF NOT EXISTS messages (
  id INT AUTO_INCREMENT PRIMARY KEY,
  sender_id INT NOT NULL,
  receiver_id INT NOT NULL,
  content TEXT,
  attachment VARCHAR(255),
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (sender_id) REFERENCES users(id),
  FOREIGN KEY (receiver_id) REFERENCES users(id)
);

-- إضافة بعض البيانات الأولية

-- إضافة المهارات
INSERT INTO skills (name, category) VALUES 
('المسح الطبوغرافي', 'تقنية'),
('نظم المعلومات الجغرافية (GIS)', 'تقنية'),
('مسح الطرق والجسور', 'تقنية'),
('التصوير الجوي بالطائرات المسيرة', 'تقنية'),
('تقنيات LiDAR', 'تقنية'),
('AutoCAD', 'برمجيات'),
('ArcGIS', 'برمجيات'),
('QGIS', 'برمجيات'),
('Pix4D', 'برمجيات'),
('Trimble Business Center', 'برمجيات'),
('Adobe Photoshop', 'برمجيات'),
('القيادة وإدارة الفريق', 'شخصية'),
('إدارة المشاريع', 'شخصية'),
('مهارات التواصل', 'شخصية'),
('حل المشكلات', 'شخصية'); 