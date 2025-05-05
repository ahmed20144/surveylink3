-- سياسات أمان جدول المستخدمين
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- سياسة القراءة: يمكن للمستخدمين قراءة بياناتهم فقط والمشرفين قراءة جميع البيانات
CREATE POLICY "المستخدمون يمكنهم قراءة بياناتهم فقط"
  ON users
  FOR SELECT
  USING (
    auth.uid()::text = id::text OR 
    auth.jwt() ->> 'role' = 'admin'
  );

-- سياسة التحديث: يمكن للمستخدمين تحديث بياناتهم فقط والمشرفين تحديث الجميع
CREATE POLICY "المستخدمون يمكنهم تحديث بياناتهم فقط"
  ON users
  FOR UPDATE
  USING (
    auth.uid()::text = id::text OR 
    auth.jwt() ->> 'role' = 'admin'
  );

-- سياسة الحذف: فقط المشرفين يمكنهم حذف المستخدمين
CREATE POLICY "فقط المشرفين يمكنهم حذف المستخدمين"
  ON users
  FOR DELETE
  USING (
    auth.jwt() ->> 'role' = 'admin'
  );

-- سياسات أمان جدول المساحين
ALTER TABLE surveyors ENABLE ROW LEVEL SECURITY;

-- سياسة القراءة: الجميع يمكنهم قراءة بيانات المساحين (عامة)
CREATE POLICY "الجميع يمكنهم قراءة بيانات المساحين"
  ON surveyors
  FOR SELECT
  USING (true);

-- سياسة التحديث: المساحون يمكنهم تحديث بياناتهم فقط والمشرفين تحديث الجميع
CREATE POLICY "المساحون يمكنهم تحديث بياناتهم فقط"
  ON surveyors
  FOR UPDATE
  USING (
    auth.uid()::text = user_id::text OR 
    auth.jwt() ->> 'role' = 'admin'
  );

-- سياسات أمان جدول الشركات
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;

-- سياسة القراءة: الجميع يمكنهم قراءة بيانات الشركات (عامة)
CREATE POLICY "الجميع يمكنهم قراءة بيانات الشركات"
  ON companies
  FOR SELECT
  USING (true);

-- سياسة التحديث: الشركات يمكنهم تحديث بياناتهم فقط والمشرفين تحديث الجميع
CREATE POLICY "الشركات يمكنهم تحديث بياناتهم فقط"
  ON companies
  FOR UPDATE
  USING (
    auth.uid()::text = user_id::text OR 
    auth.jwt() ->> 'role' = 'admin'
  );

-- سياسات أمان جدول المشاريع
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- سياسة القراءة: الجميع يمكنهم قراءة المشاريع (عامة)
CREATE POLICY "الجميع يمكنهم قراءة المشاريع"
  ON projects
  FOR SELECT
  USING (true);

-- سياسة التحديث: فقط مالك الشركة والمشرفين يمكنهم تحديث المشاريع
CREATE POLICY "فقط مالك الشركة والمشرفين يمكنهم تحديث المشاريع"
  ON projects
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM companies c 
      WHERE c.id = projects.company_id 
      AND c.user_id::text = auth.uid()::text
    ) OR 
    auth.jwt() ->> 'role' = 'admin'
  );

-- سياسات أمان جدول الوظائف
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;

-- سياسة القراءة: الجميع يمكنهم قراءة الوظائف (عامة)
CREATE POLICY "الجميع يمكنهم قراءة الوظائف"
  ON jobs
  FOR SELECT
  USING (true);

-- سياسة التحديث: فقط مالك الشركة والمشرفين يمكنهم تحديث الوظائف
CREATE POLICY "فقط مالك الشركة والمشرفين يمكنهم تحديث الوظائف"
  ON jobs
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM companies c 
      WHERE c.id = jobs.company_id 
      AND c.user_id::text = auth.uid()::text
    ) OR 
    auth.jwt() ->> 'role' = 'admin'
  );

-- سياسات أمان جدول المزادات
ALTER TABLE auctions ENABLE ROW LEVEL SECURITY;

-- سياسة القراءة: الجميع يمكنهم قراءة المزادات (عامة)
CREATE POLICY "الجميع يمكنهم قراءة المزادات"
  ON auctions
  FOR SELECT
  USING (true);

-- سياسة التحديث: فقط مالك المزاد والمشرفين يمكنهم تحديث المزادات
CREATE POLICY "فقط مالك المزاد والمشرفين يمكنهم تحديث المزادات"
  ON auctions
  FOR UPDATE
  USING (
    project_owner_id::text = auth.uid()::text OR 
    auth.jwt() ->> 'role' = 'admin'
  );

-- سياسات أمان جدول عروض المزادات
ALTER TABLE auction_bids ENABLE ROW LEVEL SECURITY;

-- سياسة القراءة: يمكن للمستخدم قراءة عروضه ومالك المزاد يمكنه قراءة جميع العروض على مزاده
CREATE POLICY "سياسة قراءة عروض المزادات"
  ON auction_bids
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM surveyors s 
      WHERE s.id = auction_bids.surveyor_id 
      AND s.user_id::text = auth.uid()::text
    ) OR
    EXISTS (
      SELECT 1 FROM auctions a 
      WHERE a.id = auction_bids.auction_id 
      AND a.project_owner_id::text = auth.uid()::text
    ) OR
    auth.jwt() ->> 'role' = 'admin'
  );

-- سياسة التحديث: فقط مالك العرض يمكنه تحديث العرض
CREATE POLICY "فقط مالك العرض يمكنه تحديث العرض"
  ON auction_bids
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM surveyors s 
      WHERE s.id = auction_bids.surveyor_id 
      AND s.user_id::text = auth.uid()::text
    ) OR
    auth.jwt() ->> 'role' = 'admin'
  );

-- سياسة الإدراج: يمكن للمساحين فقط إضافة عروض
CREATE POLICY "يمكن للمساحين فقط إضافة عروض"
  ON auction_bids
  FOR INSERT
  WITH CHECK (
    auth.jwt() ->> 'role' = 'surveyor'
  );

-- سياسات أمان جدول المنشورات
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- سياسة القراءة: الجميع يمكنهم قراءة المنشورات (عامة)
CREATE POLICY "الجميع يمكنهم قراءة المنشورات"
  ON posts
  FOR SELECT
  USING (true);

-- سياسة التحديث: فقط كاتب المنشور والمشرفين يمكنهم تحديث المنشورات
CREATE POLICY "فقط كاتب المنشور والمشرفين يمكنهم تحديث المنشورات"
  ON posts
  FOR UPDATE
  USING (
    user_id::text = auth.uid()::text OR 
    auth.jwt() ->> 'role' = 'admin'
  );

-- سياسة الإدراج: المستخدمون المسجلون فقط يمكنهم إضافة منشورات
CREATE POLICY "المستخدمون المسجلون فقط يمكنهم إضافة منشورات"
  ON posts
  FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

-- سياسات أمان جدول التعليقات
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- سياسة القراءة: الجميع يمكنهم قراءة التعليقات (عامة)
CREATE POLICY "الجميع يمكنهم قراءة التعليقات"
  ON comments
  FOR SELECT
  USING (true);

-- سياسة التحديث: فقط كاتب التعليق والمشرفين يمكنهم تحديث التعليقات
CREATE POLICY "فقط كاتب التعليق والمشرفين يمكنهم تحديث التعليقات"
  ON comments
  FOR UPDATE
  USING (
    user_id::text = auth.uid()::text OR 
    auth.jwt() ->> 'role' = 'admin'
  );

-- سياسة الإدراج: المستخدمون المسجلون فقط يمكنهم إضافة تعليقات
CREATE POLICY "المستخدمون المسجلون فقط يمكنهم إضافة تعليقات"
  ON comments
  FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

-- سياسات أمان جدول الإعجابات
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;

-- سياسة القراءة: الجميع يمكنهم رؤية الإعجابات
CREATE POLICY "الجميع يمكنهم رؤية الإعجابات"
  ON likes
  FOR SELECT
  USING (true);

-- سياسة الإدراج: المستخدمون المسجلون فقط يمكنهم إضافة إعجابات
CREATE POLICY "المستخدمون المسجلون فقط يمكنهم إضافة إعجابات"
  ON likes
  FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

-- سياسة الحذف: المستخدمون يمكنهم حذف إعجاباتهم فقط
CREATE POLICY "المستخدمون يمكنهم حذف إعجاباتهم فقط"
  ON likes
  FOR DELETE
  USING (
    user_id::text = auth.uid()::text OR 
    auth.jwt() ->> 'role' = 'admin'
  );

-- سياسات أمان جدول التقييمات
ALTER TABLE ratings ENABLE ROW LEVEL SECURITY;

-- سياسة القراءة: الجميع يمكنهم قراءة التقييمات (عامة)
CREATE POLICY "الجميع يمكنهم قراءة التقييمات"
  ON ratings
  FOR SELECT
  USING (true);

-- سياسة الإدراج: المستخدمون المسجلون فقط يمكنهم إضافة تقييمات
CREATE POLICY "المستخدمون المسجلون فقط يمكنهم إضافة تقييمات"
  ON ratings
  FOR INSERT
  WITH CHECK (
    auth.uid() IS NOT NULL AND
    rater_user_id::text = auth.uid()::text
  );

-- سياسة التحديث: المستخدمون يمكنهم تحديث تقييماتهم فقط
CREATE POLICY "المستخدمون يمكنهم تحديث تقييماتهم فقط"
  ON ratings
  FOR UPDATE
  USING (
    rater_user_id::text = auth.uid()::text OR 
    auth.jwt() ->> 'role' = 'admin'
  );

-- سياسات أمان جدول الشهادات
ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;

-- سياسة القراءة: الجميع يمكنهم قراءة الشهادات (عامة)
CREATE POLICY "الجميع يمكنهم قراءة الشهادات"
  ON certificates
  FOR SELECT
  USING (true);

-- سياسة التحديث: المستخدمون يمكنهم تحديث شهاداتهم فقط
CREATE POLICY "المستخدمون يمكنهم تحديث شهاداتهم فقط"
  ON certificates
  FOR UPDATE
  USING (
    user_id::text = auth.uid()::text OR 
    auth.jwt() ->> 'role' = 'admin'
  );

-- سياسة الإدراج: المستخدمون المسجلون فقط يمكنهم إضافة شهادات لأنفسهم
CREATE POLICY "المستخدمون المسجلون فقط يمكنهم إضافة شهادات لأنفسهم"
  ON certificates
  FOR INSERT
  WITH CHECK (
    auth.uid() IS NOT NULL AND
    user_id::text = auth.uid()::text
  );

-- سياسات أمان جدول الخبرات
ALTER TABLE experiences ENABLE ROW LEVEL SECURITY;

-- سياسة القراءة: الجميع يمكنهم قراءة الخبرات (عامة)
CREATE POLICY "الجميع يمكنهم قراءة الخبرات"
  ON experiences
  FOR SELECT
  USING (true);

-- سياسة التحديث: المستخدمون يمكنهم تحديث خبراتهم فقط
CREATE POLICY "المستخدمون يمكنهم تحديث خبراتهم فقط"
  ON experiences
  FOR UPDATE
  USING (
    user_id::text = auth.uid()::text OR 
    auth.jwt() ->> 'role' = 'admin'
  );

-- سياسة الإدراج: المستخدمون المسجلون فقط يمكنهم إضافة خبرات لأنفسهم
CREATE POLICY "المستخدمون المسجلون فقط يمكنهم إضافة خبرات لأنفسهم"
  ON experiences
  FOR INSERT
  WITH CHECK (
    auth.uid() IS NOT NULL AND
    user_id::text = auth.uid()::text
  ); 