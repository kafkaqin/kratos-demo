-- CREATE TABLE following_x (
--                              id BIGINT AUTO_INCREMENT PRIMARY KEY,
--                              user_id BIGINT NOT NULL, -- 发起关注的用户
--                              following_id BIGINT NOT NULL, -- 被关注的用户
--                              created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- ) ENGINE=InnoDB; -- 关注表
--
-- CREATE TABLE follower_x (
--                             id BIGINT AUTO_INCREMENT PRIMARY KEY,
--                             user_id BIGINT NOT NULL, -- 被关注的用户
--                             follower_id BIGINT NOT NULL, -- 粉丝的用户
--                             created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- ) ENGINE=InnoDB; -- 粉丝表

-- 数据源使用mongodb存储


-- 推送 红点表
drop table  if exists user_red_dot;
CREATE TABLE user_red_dot (
                              user_id INT NOT NULL,
                              red_dot_type VARCHAR(255) NOT NULL,
                              status BOOLEAN DEFAULT FALSE,  -- TRUE为已查看，FALSE为未查看
                              last_updated_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                              PRIMARY KEY (user_id, red_dot_type)
);



-- 推荐关系表
-- 推荐code生成规则: AES加密 然后加随机字符串 ,随机字符串需要存储在数据库中(mongodb中也行)
drop table  if exists referral_relationship;
CREATE TABLE referral_relationship (
                                       id SERIAL PRIMARY KEY,            -- 唯一标识
                                       referrer_user_id INT NOT NULL,    -- 推荐人 ID (推荐者)
                                       referred_user_id INT NOT NULL,    -- 被推荐人 ID
                                       referral_type int,  --推荐类型： 用户推荐用户，店主推荐店主，店主推荐用户，代理推荐用户
                                       referral_code VARCHAR(50),        -- 推荐码，或二维码
                                       referral_url VARCHAR(255),        -- 推荐url
                                       referral_source VARCHAR(255),     -- 推荐来源：例如“微信分享”，“二维码”等
                                       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- 推荐时间
                                       updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- 更新时间
    -- 是否是星标用户
);

-- 推荐奖励表
drop table  if exists referral_rewards;
CREATE TABLE referral_rewards (
                                  id SERIAL PRIMARY KEY,            -- 唯一标识
                                  referral_relationship_id INT NOT NULL,  -- 关联的推荐关系 ID
                                  referral_reward_rules_id INT NOT NULL,
                                  reward_type VARCHAR(50) NOT NULL,  -- 奖励类型，如"积分"、"现金"等
                                  reward_amount DECIMAL(10, 2) NOT NULL,  -- 奖励金额/数量
                                  status VARCHAR(20) DEFAULT 'pending',  -- 奖励状态，'pending'、'rewarded'等
                                  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- 奖励时间
                                  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- 更新时间
);
---- 活动信息表
-- 更新到钱包或者更新积分
-- 店主 推荐 client_ip  获取mac地址 region_ori
drop table  if exists referral_reward_rules;
CREATE TABLE referral_reward_rules (
                                       id SERIAL PRIMARY KEY,            -- 唯一标识
                                       rule_name VARCHAR(255) NOT NULL,   -- 规则名称，便于识别
                                       referral_type int,  --推荐类型： 用户推荐用户，店主推荐店主，店主推荐用户，代理推荐用户
                                       reward_type VARCHAR(50) NOT NULL,  -- 奖励类型，积分、现金等
                                       reward_amount DECIMAL(10, 2) NOT NULL,  -- 奖励金额（或积分数量）
                                       condition_type VARCHAR(50) NOT NULL,  -- 奖励条件类型，如“首次充值”，“注册成功”等
                                       condition_value VARCHAR(255),     -- 奖励条件的具体值，如“首次充值满100元”或“注册后5天内首次投注”
                                       status VARCHAR(20) DEFAULT 'active',  -- 规则状态，'active' 或 'inactive' 表示当前规则是否有效
                                       start_date TIMESTAMP,             -- 规则生效的开始时间
                                       end_date TIMESTAMP,               -- 规则的结束时间（如果有时效性）
                                       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- 规则创建时间
                                       updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP   -- 规则最后更新时间
    -- 推荐用户 推荐店主
);

-- 防作弊机制：引入验证码、IP 限制等方式，防止恶意刷单或虚假推荐。幂等性
-- 防止刷单
-- 投注红点
-- 活动红点
-- 开奖红点
-- 创建彩票店主表
-- 创建店主表

-- platform表
drop table if exists platform_user;
CREATE TABLE if not exists platform_user (
                                             platform_user_id bigserial PRIMARY KEY,
                                             avatar VARCHAR(255),
    login_password VARCHAR(255) NOT NULL,
    payment_password VARCHAR(255),
    role VARCHAR(255),
    real_name VARCHAR(50) NOT NULL,
    id_card_number VARCHAR(18) UNIQUE NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
                             );

-- 添加表和字段的注释
COMMENT ON TABLE platform_user IS 'platform user信息表';
COMMENT ON COLUMN platform_user.platform_user_id IS 'snowflake generator';
COMMENT ON COLUMN platform_user.avatar IS '店主头像链接或文件路径';
COMMENT ON COLUMN platform_user.login_password IS '登录密码（加密存储）';
COMMENT ON COLUMN platform_user.payment_password IS '支付密码（加密存储）';
COMMENT ON COLUMN platform_user.real_name IS '真实姓名';
COMMENT ON COLUMN platform_user.id_card_number IS '身份证号码';
COMMENT ON COLUMN platform_user.phone_number IS '电话号码';
COMMENT ON COLUMN platform_user.created_at IS '创建时间';
COMMENT ON COLUMN platform_user.updated_at IS '最后修改时间';

-- 创建彩票店主表
-- 店主/管家表
drop table if exists shopkeeper;
CREATE TABLE if not exists shopkeeper (
                                          shopkeeper_id bigserial PRIMARY KEY,
                                          platform_user_id bigint,
                                          referrer_user_id INT,  -- 推荐人 ID (nullable, 只有被推荐人有值)
                                          avatar VARCHAR(255),
    login_password VARCHAR(255) NOT NULL,
    payment_password VARCHAR(255),
    real_name VARCHAR(50) NOT NULL,
    id_card_number VARCHAR(18) UNIQUE NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
                             );

-- 添加表和字段的注释
COMMENT ON TABLE shopkeeper IS '彩票系统店主信息表';
COMMENT ON COLUMN shopkeeper.shopkeeper_id IS '自增ID';
COMMENT ON COLUMN shopkeeper.avatar IS '店主头像链接或文件路径';
COMMENT ON COLUMN shopkeeper.login_password IS '登录密码（加密存储）';
COMMENT ON COLUMN shopkeeper.payment_password IS '支付密码（加密存储）';
COMMENT ON COLUMN shopkeeper.real_name IS '真实姓名';
COMMENT ON COLUMN shopkeeper.id_card_number IS '身份证号码';
COMMENT ON COLUMN shopkeeper.phone_number IS '电话号码';
COMMENT ON COLUMN shopkeeper.created_at IS '创建时间';
COMMENT ON COLUMN shopkeeper.updated_at IS '最后修改时间';

-- 添加触发器自动更新修改时间
CREATE OR REPLACE FUNCTION update_modified_column()
    RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_lottery_shop_owner_modtime
    BEFORE UPDATE ON shopkeeper
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_column();

drop table if exists customer;
CREATE TABLE if not exists customer (
                                        id bigserial PRIMARY KEY,
                                        platform_user_id bigint,
                                        shopkeeper_id bigint,
                                        referrer_user_id INT,  -- 推荐人 ID (nullable, 只有被推荐人有值)
                                        is_agent BOOLEAN DEFAULT FALSE,
                                        is_star_user BOOLEAN DEFAULT FALSE,  -- 是否为星标用户（默认为否）
                                        avatar VARCHAR(255),
    login_password VARCHAR(255) NOT NULL,
    payment_password VARCHAR(255),
    real_name VARCHAR(50) NOT NULL,
    id_card_number VARCHAR(18) UNIQUE NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
                             );

-- 员工表
drop table if exists staff;
create table staff(
                      id bigserial PRIMARY KEY,
                      platform_user_id bigint,
                      shopkeeper_id bigint,
                      referrer_user_id INT,  -- 推荐人 ID (nullable, 只有被推荐人有值)
                      is_agent BOOLEAN DEFAULT FALSE,
                      is_star_user BOOLEAN DEFAULT FALSE,  -- 是否为星标用户（默认为否）
                      avatar VARCHAR(255),
                      login_password VARCHAR(255) NOT NULL,
                      payment_password VARCHAR(255),
                      real_name VARCHAR(50) NOT NULL,
                      id_card_number VARCHAR(18) UNIQUE NOT NULL,
                      phone_number VARCHAR(20) UNIQUE NOT NULL,
                      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                      updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP

);

-- 创建登录信息表
drop table  if exists lottery_login_info;
CREATE TABLE lottery_login_info (
                                    id SERIAL PRIMARY KEY,
                                    user_id bigint,
                                    username VARCHAR(50) NOT NULL UNIQUE,
                                    email VARCHAR(100),
                                    phone_number VARCHAR(20),
                                    last_login_time TIMESTAMP WITH TIME ZONE,
                                    last_login_ip VARCHAR(45),
                                    login_attempts INTEGER DEFAULT 0,
                                    is_locked BOOLEAN DEFAULT false,
                                    lock_until TIMESTAMP WITH TIME ZONE,
                                    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
                                    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 添加表和字段的注释
COMMENT ON TABLE lottery_login_info IS '彩票系统登录信息表';
COMMENT ON COLUMN lottery_login_info.id IS '自增ID';
COMMENT ON COLUMN lottery_login_info.username IS '用户名';
COMMENT ON COLUMN lottery_login_info.email IS '电子邮箱';
COMMENT ON COLUMN lottery_login_info.phone_number IS '电话号码';
COMMENT ON COLUMN lottery_login_info.last_login_time IS '最后登录时间';
COMMENT ON COLUMN lottery_login_info.last_login_ip IS '最后登录IP地址';
COMMENT ON COLUMN lottery_login_info.login_attempts IS '登录尝试次数';
COMMENT ON COLUMN lottery_login_info.is_locked IS '账户是否锁定';
COMMENT ON COLUMN lottery_login_info.lock_until IS '账户锁定截止时间';
COMMENT ON COLUMN lottery_login_info.status IS '账户状态';
COMMENT ON COLUMN lottery_login_info.created_at IS '创建时间';
COMMENT ON COLUMN lottery_login_info.updated_at IS '最后修改时间';

-- 添加触发器自动更新修改时间
CREATE OR REPLACE FUNCTION update_modified_column()
    RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_lottery_login_info_modtime
    BEFORE UPDATE ON lottery_login_info
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_column();

-- 添加唯一性约束，确保用户名、邮箱、手机号不重复
CREATE UNIQUE INDEX idx_unique_username ON lottery_login_info(username);
CREATE UNIQUE INDEX idx_unique_email ON lottery_login_info(email) WHERE email IS NOT NULL;
CREATE UNIQUE INDEX idx_unique_phone ON lottery_login_info(phone_number) WHERE phone_number IS NOT NULL;


-- 创建操作审计表
drop table  if exists lottery_operation_audit;
CREATE TABLE lottery_operation_audit (
                                         id SERIAL PRIMARY KEY,
                                         user_id bigint,
                                         operator_type VARCHAR(20) NOT NULL CHECK (operator_type IN ('shop_owner', 'system', 'admin')),
                                         operation_type VARCHAR(50) NOT NULL,
                                         operation_module VARCHAR(50) NOT NULL,
                                         operation_description TEXT,
                                         request_ip VARCHAR(45),
                                         request_location VARCHAR(100),
                                         request_user_agent TEXT,
                                         operation_result VARCHAR(20) NOT NULL CHECK (operation_result IN ('success', 'failure', 'partial')),
                                         operation_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                         operation_details JSONB,
                                         risk_level INTEGER DEFAULT 0 CHECK (risk_level BETWEEN 0 AND 10)
);

-- 添加表和字段的注释
COMMENT ON TABLE lottery_operation_audit IS '彩票系统操作审计日志表';
COMMENT ON COLUMN lottery_operation_audit.id IS '自增ID';
COMMENT ON COLUMN lottery_operation_audit.operator_type IS '操作者类型';
COMMENT ON COLUMN lottery_operation_audit.operation_type IS '操作类型';
COMMENT ON COLUMN lottery_operation_audit.operation_module IS '操作模块';
COMMENT ON COLUMN lottery_operation_audit.operation_description IS '操作描述';
COMMENT ON COLUMN lottery_operation_audit.request_ip IS '请求IP地址';
COMMENT ON COLUMN lottery_operation_audit.request_location IS '请求地理位置';
COMMENT ON COLUMN lottery_operation_audit.request_user_agent IS '用户代理信息';
COMMENT ON COLUMN lottery_operation_audit.operation_result IS '操作结果';
COMMENT ON COLUMN lottery_operation_audit.operation_time IS '操作时间';
COMMENT ON COLUMN lottery_operation_audit.operation_details IS '操作详细信息（JSON格式）';
COMMENT ON COLUMN lottery_operation_audit.risk_level IS '操作风险等级';

-- 创建索引以提高查询性能
CREATE INDEX idx_lottery_audit_operation_type ON lottery_operation_audit(operation_type);
CREATE INDEX idx_lottery_audit_operation_time ON lottery_operation_audit(operation_time);
CREATE INDEX idx_lottery_audit_operation_result ON lottery_operation_audit(operation_result);
CREATE INDEX idx_lottery_audit_risk_level ON lottery_operation_audit(risk_level);

-- 创建会员等级表
drop table  if exists lottery_member_level;
CREATE TABLE lottery_member_level (
                                      id SERIAL PRIMARY KEY,
                                      level_code VARCHAR(20) NOT NULL UNIQUE,
                                      level_name VARCHAR(50) NOT NULL,
                                      level_order INTEGER NOT NULL UNIQUE,
                                      min_points INTEGER NOT NULL DEFAULT 0,
                                      max_points INTEGER,
                                      discount_rate NUMERIC(5,2) DEFAULT 0 CHECK (discount_rate BETWEEN 0 AND 100),
                                      daily_max_bet_amount NUMERIC(12,2),
                                      daily_max_winning_amount NUMERIC(12,2),
                                      upgrade_conditions JSONB,
                                      status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
                                      created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                      updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 添加表和字段的注释
COMMENT ON TABLE lottery_member_level IS '彩票系统会员等级表';
COMMENT ON COLUMN lottery_member_level.id IS '自增ID';
COMMENT ON COLUMN lottery_member_level.level_code IS '等级唯一编码';
COMMENT ON COLUMN lottery_member_level.level_name IS '等级名称';
COMMENT ON COLUMN lottery_member_level.level_order IS '等级排序';
COMMENT ON COLUMN lottery_member_level.min_points IS '达到该等级的最小积分';
COMMENT ON COLUMN lottery_member_level.max_points IS '该等级的最大积分';
COMMENT ON COLUMN lottery_member_level.discount_rate IS '会员折扣率';
COMMENT ON COLUMN lottery_member_level.daily_max_bet_amount IS '每日最大投注金额';
COMMENT ON COLUMN lottery_member_level.daily_max_winning_amount IS '每日最大中奖金额';
COMMENT ON COLUMN lottery_member_level.upgrade_conditions IS '升级条件（JSON格式）';
COMMENT ON COLUMN lottery_member_level.status IS '等级状态';
COMMENT ON COLUMN lottery_member_level.created_at IS '创建时间';
COMMENT ON COLUMN lottery_member_level.updated_at IS '最后修改时间';

-- 创建触发器自动更新修改时间
CREATE OR REPLACE FUNCTION update_modified_column()
    RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_lottery_member_level_modtime
    BEFORE UPDATE ON lottery_member_level
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_column();

-- 插入初始会员等级数据的存储过程
CREATE OR REPLACE PROCEDURE init_member_levels()
    LANGUAGE plpgsql
AS $$
BEGIN
INSERT INTO lottery_member_level (
    level_code,
    level_name,
    level_order,
    min_points,
    max_points,
    discount_rate,
    daily_max_bet_amount,
    daily_max_winning_amount,
    upgrade_conditions
) VALUES
      ('BRONZE', '青铜会员', 1, 0, 1000, 5.00, 5000.00, 10000.00,
       '{"min_betting_times": 10, "min_total_betting_amount": 1000}'),

      ('SILVER', '白银会员', 2, 1001, 5000, 10.00, 10000.00, 50000.00,
       '{"min_betting_times": 50, "min_total_betting_amount": 5000}'),

      ('GOLD', '黄金会员', 3, 5001, 20000, 15.00, 50000.00, 200000.00,
       '{"min_betting_times": 200, "min_total_betting_amount": 20000}'),

      ('PLATINUM', '铂金会员', 4, 20001, 50000, 20.00, 100000.00, 500000.00,
       '{"min_betting_times": 500, "min_total_betting_amount": 50000}'),

      ('DIAMOND', '钻石会员', 5, 50001, NULL, 25.00, 200000.00, 1000000.00,
       '{"min_betting_times": 1000, "min_total_betting_amount": 100000}');
END;
$$;
-- 执行初始化存储过程
CALL init_member_levels();

--
-- 创建钱包表
drop table if exists lottery_wallet;
CREATE TABLE if not exists lottery_wallet (
                                              id SERIAL PRIMARY KEY,
                                              user_id bigint,
                                              balance NUMERIC(12,2) NOT NULL DEFAULT 0.00 CHECK (balance >= 0),
    frozen_balance NUMERIC(12,2) NOT NULL DEFAULT 0.00 CHECK (frozen_balance >= 0),
    total_recharge_amount NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    total_withdrawal_amount NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    total_betting_amount NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    total_winning_amount NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    currency VARCHAR(10) NOT NULL DEFAULT 'CNY',
    wallet_status VARCHAR(20) NOT NULL DEFAULT 'active'
    CHECK (wallet_status IN ('active', 'frozen', 'disabled')),
    last_transaction_time TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
                             );

-- 添加表和字段的注释
COMMENT ON TABLE lottery_wallet IS '彩票系统店主钱包表';
COMMENT ON COLUMN lottery_wallet.id IS '自增ID';
COMMENT ON COLUMN lottery_wallet.balance IS '可用余额';
COMMENT ON COLUMN lottery_wallet.frozen_balance IS '冻结余额';
COMMENT ON COLUMN lottery_wallet.total_recharge_amount IS '累计充值金额';
COMMENT ON COLUMN lottery_wallet.total_withdrawal_amount IS '累计提现金额';
COMMENT ON COLUMN lottery_wallet.total_betting_amount IS '累计投注金额';
COMMENT ON COLUMN lottery_wallet.total_winning_amount IS '累计中奖金额';
COMMENT ON COLUMN lottery_wallet.currency IS '货币类型';
COMMENT ON COLUMN lottery_wallet.wallet_status IS '钱包状态';
COMMENT ON COLUMN lottery_wallet.last_transaction_time IS '最后交易时间';
COMMENT ON COLUMN lottery_wallet.created_at IS '创建时间';
COMMENT ON COLUMN lottery_wallet.updated_at IS '最后修改时间';

-- 创建触发器自动更新修改时间
CREATE OR REPLACE FUNCTION update_modified_column()
    RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_lottery_wallet_modtime
    BEFORE UPDATE ON lottery_wallet
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_column();

-- 钱包交易明细表
drop table if exists lottery_wallet_transaction;
CREATE TABLE if not exists lottery_wallet_transaction (
                                                          id SERIAL PRIMARY KEY,
                                                          wallet_id INTEGER NOT NULL,
                                                          transaction_type VARCHAR(30) NOT NULL
    CHECK (transaction_type IN (
           'recharge', 'withdrawal', 'betting', 'winning',
           'commission', 'refund', 'adjustment'
                               )),
    amount NUMERIC(12,2) NOT NULL,
    pre_balance NUMERIC(12,2) NOT NULL,
    post_balance NUMERIC(12,2) NOT NULL,
    transaction_status VARCHAR(20) NOT NULL
    CHECK (transaction_status IN ('success', 'pending', 'failed')),
    related_order_id VARCHAR(50),
    transaction_description TEXT,
    transaction_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                   operator_type VARCHAR(20) NOT NULL
    CHECK (operator_type IN ('system', 'manual', 'api'))
    );

-- 添加交易明细表注释
COMMENT ON TABLE lottery_wallet_transaction IS '彩票系统钱包交易明细表';
COMMENT ON COLUMN lottery_wallet_transaction.id IS '自增ID';
COMMENT ON COLUMN lottery_wallet_transaction.wallet_id IS '关联钱包ID';
COMMENT ON COLUMN lottery_wallet_transaction.transaction_type IS '交易类型';
COMMENT ON COLUMN lottery_wallet_transaction.amount IS '交易金额';
COMMENT ON COLUMN lottery_wallet_transaction.pre_balance IS '交易前余额';
COMMENT ON COLUMN lottery_wallet_transaction.post_balance IS '交易后余额';
COMMENT ON COLUMN lottery_wallet_transaction.transaction_status IS '交易状态';
COMMENT ON COLUMN lottery_wallet_transaction.related_order_id IS '关联订单ID';
COMMENT ON COLUMN lottery_wallet_transaction.transaction_description IS '交易描述';
COMMENT ON COLUMN lottery_wallet_transaction.transaction_time IS '交易时间';
COMMENT ON COLUMN lottery_wallet_transaction.operator_type IS '操作类型';

-- 创建交易明细表索引
CREATE INDEX idx_wallet_transaction_wallet_id ON lottery_wallet_transaction(wallet_id);
CREATE INDEX idx_wallet_transaction_type ON lottery_wallet_transaction(transaction_type);
CREATE INDEX idx_wallet_transaction_time ON lottery_wallet_transaction(transaction_time);
CREATE INDEX idx_wallet_transaction_status ON lottery_wallet_transaction(transaction_status);

---
-- 创建店铺表
drop table if exists lottery_shop;
CREATE TABLE lottery_shop (
                              id SERIAL PRIMARY KEY,
                              shopkeeper_id bigint,
                              shop_code VARCHAR(50) NOT NULL UNIQUE,
                              shop_name VARCHAR(100) NOT NULL,
                              province VARCHAR(50),
                              city VARCHAR(50),
                              district VARCHAR(50),
                              detailed_address TEXT,
                              shop_type VARCHAR(30) NOT NULL CHECK (shop_type IN ('physical', 'online', 'hybrid')),
                              business_license_number VARCHAR(50) UNIQUE,
                              business_license_image VARCHAR(255),
                              longitude NUMERIC(10,7),
                              latitude NUMERIC(10,7),
                              shop_size NUMERIC(8,2),
                              employee_count INTEGER DEFAULT 0,
                              daily_ticket_sales_volume INTEGER DEFAULT 0,
                              daily_sales_amount NUMERIC(12,2) DEFAULT 0.00,
                              commission_rate NUMERIC(5,2) DEFAULT 0 CHECK (commission_rate BETWEEN 0 AND 100),
                              shop_status VARCHAR(20) NOT NULL DEFAULT 'active'
                                  CHECK (shop_status IN ('active', 'pending', 'suspended', 'closed')),
                              is_primary_shop BOOLEAN DEFAULT FALSE,
                              registration_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                              last_active_time TIMESTAMP WITH TIME ZONE,
                              created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                              updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 添加表和字段的注释
COMMENT ON TABLE lottery_shop IS '彩票系统店铺信息表';
COMMENT ON COLUMN lottery_shop.id IS '自增ID';
COMMENT ON COLUMN lottery_shop.shopkeeper_id IS '店主ID';
COMMENT ON COLUMN lottery_shop.shop_code IS '店铺唯一编码';
COMMENT ON COLUMN lottery_shop.shop_name IS '店铺名称';
COMMENT ON COLUMN lottery_shop.province IS '省份';
COMMENT ON COLUMN lottery_shop.city IS '城市';
COMMENT ON COLUMN lottery_shop.district IS '区县';
COMMENT ON COLUMN lottery_shop.detailed_address IS '详细地址';
COMMENT ON COLUMN lottery_shop.shop_type IS '店铺类型';
COMMENT ON COLUMN lottery_shop.business_license_number IS '营业执照号';
COMMENT ON COLUMN lottery_shop.business_license_image IS '营业执照图片';
COMMENT ON COLUMN lottery_shop.longitude IS '经度';
COMMENT ON COLUMN lottery_shop.latitude IS '纬度';
COMMENT ON COLUMN lottery_shop.shop_size IS '店铺面积（平方米）';
COMMENT ON COLUMN lottery_shop.employee_count IS '员工数量';
COMMENT ON COLUMN lottery_shop.daily_ticket_sales_volume IS '每日彩票销售量';
COMMENT ON COLUMN lottery_shop.daily_sales_amount IS '每日销售金额';
COMMENT ON COLUMN lottery_shop.commission_rate IS '佣金比例';
COMMENT ON COLUMN lottery_shop.shop_status IS '店铺状态';
COMMENT ON COLUMN lottery_shop.is_primary_shop IS '是否为主店';
COMMENT ON COLUMN lottery_shop.registration_time IS '注册时间';
COMMENT ON COLUMN lottery_shop.last_active_time IS '最后活跃时间';
COMMENT ON COLUMN lottery_shop.created_at IS '创建时间';
COMMENT ON COLUMN lottery_shop.updated_at IS '最后修改时间';

-- 创建触发器自动更新修改时间
CREATE OR REPLACE FUNCTION update_modified_column()
    RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_lottery_shop_modtime
    BEFORE UPDATE ON lottery_shop
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_column();

-- 创建店铺运营数据表
drop table if exists  lottery_shop_daily_stats;
CREATE TABLE lottery_shop_daily_stats (
                                          id SERIAL PRIMARY KEY,
                                          shop_id INTEGER NOT NULL,
                                          stat_date DATE NOT NULL,
                                          total_ticket_sales_volume INTEGER DEFAULT 0,
                                          total_sales_amount NUMERIC(12,2) DEFAULT 0.00,
                                          total_commission_amount NUMERIC(12,2) DEFAULT 0.00,
                                          ticket_types_sold JSONB,
                                          peak_sales_hour INTEGER,
                                          created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                          UNIQUE(shop_id, stat_date)
);

-- 添加店铺运营数据表注释
COMMENT ON TABLE lottery_shop_daily_stats IS '彩票系统店铺每日运营统计表';
COMMENT ON COLUMN lottery_shop_daily_stats.id IS '自增ID';
COMMENT ON COLUMN lottery_shop_daily_stats.shop_id IS '店铺ID';
COMMENT ON COLUMN lottery_shop_daily_stats.stat_date IS '统计日期';
COMMENT ON COLUMN lottery_shop_daily_stats.total_ticket_sales_volume IS '总彩票销售量';
COMMENT ON COLUMN lottery_shop_daily_stats.total_sales_amount IS '总销售金额';
COMMENT ON COLUMN lottery_shop_daily_stats.total_commission_amount IS '总佣金金额';
COMMENT ON COLUMN lottery_shop_daily_stats.ticket_types_sold IS '销售的彩票类型及数量';
COMMENT ON COLUMN lottery_shop_daily_stats.peak_sales_hour IS '销售高峰小时';

drop table if exists partner_store;
CREATE TABLE partner_store (
                               id SERIAL PRIMARY KEY,  -- Store database auto-incremented ID
                               shopkeeper_id bigint,
                               partner_shopkeeper_id INT NOT NULL,  -- Store owner ID, references the owner table
                               cooperation_status VARCHAR(50) DEFAULT 'Pending',  -- Cooperation status (e.g., Pending, Active, Terminated)
                               cooperation_start_date TIMESTAMP,  -- Cooperation start date
                               cooperation_end_date TIMESTAMP,  -- Cooperation end date (if applicable)
                               created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Creation time
                               updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP   -- Update time
);

-- Add comments on columns
COMMENT ON COLUMN partner_store.id IS 'Store database auto-incremented ID';
COMMENT ON COLUMN partner_store.cooperation_status IS 'Cooperation status (Pending, Active, Terminated)';
COMMENT ON COLUMN partner_store.cooperation_start_date IS 'Cooperation start date';
COMMENT ON COLUMN partner_store.cooperation_end_date IS 'Cooperation end date';
COMMENT ON COLUMN partner_store.created_at IS 'Creation time';
COMMENT ON COLUMN partner_store.updated_at IS 'Update time';

-- -- 创建店铺每日统计存储过程
-- CREATE OR REPLACE PROCEDURE update_shop_daily_stats(
--     p_shop_id INTEGER,
--     p_stat_date DATE DEFAULT CURRENT_DATE
-- )
--     LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     -- 插入或更新每日统计数据
--     INSERT INTO lottery_shop_daily_stats (
--         shop_id,
--         stat_date,
--         total_ticket_sales_volume,
--         total_sales_amount,
--         total_commission_amount,
--         ticket_types_sold,
--         peak_sales_hour
--     )
--     SELECT
--         p_shop_id,
--         p_stat_date,
--         COALESCE(SUM(ticket_volume), 0),
--         COALESCE(SUM(sales_amount), 0),
--         COALESCE(SUM(sales_amount * shop.commission_rate / 100), 0),
--         (SELECT jsonb_object_agg(ticket_type, ticket_volume)
--          FROM (
--                   SELECT ticket_type, SUM(ticket_volume) as ticket_volume
--                   FROM lottery_ticket_sales
--                   WHERE shop_id = p_shop_id AND sale_time::DATE = p_stat_date
--                   GROUP BY ticket_type
--               ) ticket_type_summary),
--         (SELECT EXTRACT(HOUR FROM sale_time)
--          FROM lottery_ticket_sales
--          WHERE shop_id = p_shop_id AND sale_time::DATE = p_stat_date
--          GROUP BY EXTRACT(HOUR FROM sale_time)
--          ORDER BY COUNT(*) DESC
--          LIMIT 1)
--     FROM lottery_ticket_sales sales
--              JOIN lottery_shop shop ON sales.shop_id = shop.id
--     WHERE sales.shop_id = p_shop_id AND sales.sale_time::DATE = p_stat_date
--     ON CONFLICT (shop_id, stat_date)
--         DO UPDATE SET
--                       total_ticket_sales_volume = EXCLUDED.total_ticket_sales_volume,
--                       total_sales_amount = EXCLUDED.total_sales_amount,
--                       total_commission_amount = EXCLUDED.total_commission_amount,
--                       ticket_types_sold = EXCLUDED.ticket_types_sold,
--                       peak_sales_hour = EXCLUDED.peak_sales_hour;
-- END;
-- $$;

-- 创建索引
CREATE INDEX idx_lottery_shop_owner_id ON lottery_shop(shopkeeper_id);
CREATE INDEX idx_lottery_shop_status ON lottery_shop(shop_status);
CREATE INDEX idx_lottery_shop_daily_stats_shop_id ON lottery_shop_daily_stats(shop_id);
CREATE INDEX idx_lottery_shop_daily_stats_date ON lottery_shop_daily_stats(stat_date);

-- 申请表
drop table if exists application;
CREATE TABLE application (
                             id SERIAL PRIMARY KEY,  -- 申请表数据库自增id
                             application_type VARCHAR(50) NOT NULL,  -- 申请类型（例如：提款申请、合作申请）
                             applicant_id INT NOT NULL,  -- 申请人ID，关联到用户或店主表
                             amount DECIMAL(15, 2),  -- 提款申请时的金额（适用于提款申请类型）
                             details TEXT,  -- 申请的详细信息（适用于合作申请类型）
                             application_status VARCHAR(50) DEFAULT '待处理',  -- 申请状态（例如：待处理、已通过、已拒绝）
                             application_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- 申请时间
                             process_date TIMESTAMP,  -- 处理时间
                             processed_by INT
);

-- 给字段添加注释
COMMENT ON COLUMN application.id IS '申请表数据库自增id';
COMMENT ON COLUMN application.application_type IS '申请类型（提款申请、合作申请等）';
COMMENT ON COLUMN application.applicant_id IS '申请人ID，关联到用户或店主表';
COMMENT ON COLUMN application.amount IS '提款申请时的金额（适用于提款申请类型）';
COMMENT ON COLUMN application.details IS '申请的详细信息（适用于合作申请类型）';
COMMENT ON COLUMN application.application_status IS '申请状态（待处理、已通过、已拒绝等）';
COMMENT ON COLUMN application.application_date IS '申请时间';
COMMENT ON COLUMN application.process_date IS '处理时间';
COMMENT ON COLUMN application.processed_by IS '处理人员ID（可以是管理员ID）';
