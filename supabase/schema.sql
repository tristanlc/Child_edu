-- ============================================
-- 成长积分打卡小程序 - Supabase 数据库结构
-- ============================================

-- 1. 用户/家庭表
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL DEFAULT '孩子',
    role VARCHAR(20) NOT NULL DEFAULT 'child', -- 'child' | 'parent'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. 用户积分表
CREATE TABLE IF NOT EXISTS user_points (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    total_points INTEGER DEFAULT 0,
    week_points INTEGER DEFAULT 0,
    total_earned INTEGER DEFAULT 0,
    total_redeemed INTEGER DEFAULT 0,
    day_streak INTEGER DEFAULT 0,
    amnesties INTEGER DEFAULT 1,
    last_check_in DATE,
    week_reset_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);

-- 3. 每日任务完成记录
CREATE TABLE IF NOT EXISTS daily_tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    task_date DATE NOT NULL,
    task_id VARCHAR(50) NOT NULL,
    task_category VARCHAR(20) NOT NULL,
    task_name VARCHAR(100) NOT NULL,
    task_points INTEGER NOT NULL,
    completed BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, task_date, task_id)
);

-- 4. 积分变动历史
CREATE TABLE IF NOT EXISTS point_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    history_type VARCHAR(20) NOT NULL, -- 'add' | 'redeem' | 'bonus' | 'adjust'
    points INTEGER NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. 愿望清单
CREATE TABLE IF NOT EXISTS wishes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    wish_type VARCHAR(20) NOT NULL, -- 'food' | 'game' | 'activity' | 'item'
    wish_type_name VARCHAR(20) NOT NULL,
    content TEXT NOT NULL,
    target_points INTEGER NOT NULL,
    status VARCHAR(20) DEFAULT 'pending', -- 'pending' | 'approved' | 'rejected' | 'fulfilled'
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fulfilled_at TIMESTAMP WITH TIME ZONE
);

-- 6. 兑换记录
CREATE TABLE IF NOT EXISTS redemptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    item_id VARCHAR(50) NOT NULL,
    item_name VARCHAR(100) NOT NULL,
    item_type VARCHAR(50),
    points_cost INTEGER NOT NULL,
    used_amnesty BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 索引优化
-- ============================================
CREATE INDEX IF NOT EXISTS idx_daily_tasks_user_date ON daily_tasks(user_id, task_date);
CREATE INDEX IF NOT EXISTS idx_point_history_user ON point_history(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_wishes_user ON wishes(user_id, status);
CREATE INDEX IF NOT EXISTS idx_redemptions_user ON redemptions(user_id, created_at DESC);

-- ============================================
-- 启用 Row Level Security (RLS)
-- ============================================

-- 启用RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_points ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE point_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE wishes ENABLE ROW LEVEL SECURITY;
ALTER TABLE redemptions ENABLE ROW LEVEL SECURITY;

-- 策略：用户只能访问自己的数据
CREATE POLICY "Users can view own data" ON users FOR SELECT USING (true);
CREATE POLICY "Users can insert own data" ON users FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update own data" ON users FOR UPDATE USING (true);

CREATE POLICY "Points can view own" ON user_points FOR SELECT USING (true);
CREATE POLICY "Points can insert own" ON user_points FOR INSERT WITH CHECK (true);
CREATE POLICY "Points can update own" ON user_points FOR UPDATE USING (true);

CREATE POLICY "Tasks can view own" ON daily_tasks FOR SELECT USING (true);
CREATE POLICY "Tasks can insert own" ON daily_tasks FOR INSERT WITH CHECK (true);
CREATE POLICY "Tasks can update own" ON daily_tasks FOR UPDATE USING (true);

CREATE POLICY "History can view own" ON point_history FOR SELECT USING (true);
CREATE POLICY "History can insert own" ON point_history FOR INSERT WITH CHECK (true);

CREATE POLICY "Wishes can view own" ON wishes FOR SELECT USING (true);
CREATE POLICY "Wishes can insert own" ON wishes FOR INSERT WITH CHECK (true);
CREATE POLICY "Wishes can update own" ON wishes FOR UPDATE USING (true);

CREATE POLICY "Redemptions can view own" ON redemptions FOR SELECT USING (true);
CREATE POLICY "Redemptions can insert own" ON redemptions FOR INSERT WITH CHECK (true);

-- ============================================
-- 初始化默认用户
-- ============================================
INSERT INTO users (id, name, role) 
VALUES ('00000000-0000-0000-0000-000000000001', '孩子', 'child')
ON CONFLICT DO NOTHING;

INSERT INTO user_points (user_id, total_points, amnesties)
VALUES ('00000000-0000-0000-0000-000000000001', 0, 1)
ON CONFLICT (user_id) DO NOTHING;
