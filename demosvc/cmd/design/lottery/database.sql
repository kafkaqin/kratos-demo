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

-- CREATE DATABASE mydatabase
--     TEMPLATE = template0
--     ENCODING = 'UTF8'
--     LC_COLLATE = 'en_US.UTF-8'
--     LC_CTYPE = 'en_US.UTF-8';

-- postgresql://username:password@hostname:port/database?options=-c%20timezone%3DUTC&client_encoding=UTF8
--
-- 推送 红点表
drop table  if exists user_red_dot;
CREATE TABLE if not EXISTS user_red_dot (
                                            user_id INT NOT NULL,
                                            red_dot_type VARCHAR(255) NOT NULL,
    status BOOLEAN DEFAULT FALSE,  -- TRUE为已查看，FALSE为未查看
    last_updated_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, red_dot_type)
    );

CREATE TYPE status AS ENUM ('active', 'inactive', 'pending');

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
    -- 新增属性
                              shop_notice TEXT, -- 店铺公告
                              shop_phone VARCHAR(20), -- 店铺电话
                              shop_wechat VARCHAR(100), -- 店铺微信
                              lottery_types VARCHAR(255)[], -- 店铺彩种类型（数组类型）
                              allow_new_user_registration BOOLEAN DEFAULT FALSE, -- 是否允许新用户注册
                              balance_transfer_enabled BOOLEAN DEFAULT FALSE, -- 余额支持开关
                              auto_dispatch_order BOOLEAN DEFAULT FALSE, -- 自动派单
                              auto_accept_order BOOLEAN DEFAULT FALSE, -- 自动接单
                              auto_accept_and_print_ticket BOOLEAN DEFAULT FALSE, -- 自动接单并出票
                              small_amount_passwordless_transfer NUMERIC(10,2) DEFAULT 0.00, -- 小额免密额度
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
COMMENT ON COLUMN lottery_shop.shop_notice IS '店铺公告';
COMMENT ON COLUMN lottery_shop.shop_phone IS '店铺联系电话';
COMMENT ON COLUMN lottery_shop.shop_wechat IS '店铺微信号';
COMMENT ON COLUMN lottery_shop.lottery_types IS '店铺支持的彩种类型数组';
COMMENT ON COLUMN lottery_shop.allow_new_user_registration IS '是否允许新用户注册';
COMMENT ON COLUMN lottery_shop.balance_transfer_enabled IS '余额支持开关';
COMMENT ON COLUMN lottery_shop.auto_dispatch_order IS '是否自动派单';
COMMENT ON COLUMN lottery_shop.auto_accept_order IS '是否自动接单';
COMMENT ON COLUMN lottery_shop.auto_accept_and_print_ticket IS '是否自动接单并出票';
COMMENT ON COLUMN lottery_shop.small_amount_passwordless_transfer IS '小额免密转账额度';
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


-- 创建彩种管理表
drop table if exists lottery_type;
CREATE TABLE lottery_type (
                              id SERIAL PRIMARY KEY,
                              lottery_code VARCHAR(50) NOT NULL UNIQUE, -- 彩种唯一编码
                              lottery_name VARCHAR(100) NOT NULL, -- 彩种名称
                              lottery_category VARCHAR(50) NOT NULL, -- 彩种分类（如：福利彩票、体育彩票）
                              lottery_type VARCHAR(50) NOT NULL, -- 玩法类型（如：数字型、乐透型、即开型）

    -- 彩种基本配置
                              min_bet_amount NUMERIC(10,2) DEFAULT 2.00, -- 最低投注金额
                              max_bet_amount NUMERIC(10,2) DEFAULT 10000.00, -- 最高投注金额
                              prize_pool_percentage NUMERIC(5,2) DEFAULT 50.00, -- 奖池分配百分比

    -- 开奖相关
                              draw_frequency VARCHAR(50), -- 开奖频率（如：每周三、每周六）
                              draw_time TIME, -- 开奖时间
                              draw_days INTEGER[], -- 开奖日期（如：[3,6]表示周三和周六）

    -- 新增属性
                              allow_group_buy BOOLEAN DEFAULT FALSE, -- 合买开关
                              user_bet_cutoff_advance_minutes INTEGER DEFAULT 5, -- 用户投注截止时间提前分钟数
                              user_min_bet_amount NUMERIC(10,2) DEFAULT 1.00, -- 用户投注最低金额
                              multi_period_bet_min_amount NUMERIC(10,2) DEFAULT 10.00, -- 追期投注最低金额

    -- 状态控制
                              is_active BOOLEAN DEFAULT TRUE, -- 是否启用
                              is_visible BOOLEAN DEFAULT TRUE, -- 是否对用户可见
                              is_sellable BOOLEAN DEFAULT TRUE, -- 是否可销售

    -- 佣金和分成
                              sales_commission_rate NUMERIC(5,2) DEFAULT 0, -- 销售佣金比例
                              agent_commission_rate NUMERIC(5,2) DEFAULT 0, -- 代理商佣金比例

    -- 系统配置
                              prize_calculation_rule JSONB, -- 奖金计算规则
                              bet_rules JSONB, -- 投注规则

    -- 审计字段
                              created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                              updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
-- 添加表注释
COMMENT ON TABLE lottery_type IS '彩种管理表';

-- 添加字段注释
COMMENT ON COLUMN lottery_type.id IS '自增主键';
COMMENT ON COLUMN lottery_type.lottery_code IS '彩种唯一编码';
COMMENT ON COLUMN lottery_type.lottery_name IS '彩种名称';
COMMENT ON COLUMN lottery_type.lottery_category IS '彩种分类';
COMMENT ON COLUMN lottery_type.lottery_type IS '玩法类型';
COMMENT ON COLUMN lottery_type.min_bet_amount IS '最低投注金额';
COMMENT ON COLUMN lottery_type.max_bet_amount IS '最高投注金额';
COMMENT ON COLUMN lottery_type.prize_pool_percentage IS '奖池分配百分比';
COMMENT ON COLUMN lottery_type.draw_frequency IS '开奖频率';
COMMENT ON COLUMN lottery_type.draw_time IS '开奖时间';
COMMENT ON COLUMN lottery_type.draw_days IS '开奖日期';
COMMENT ON COLUMN lottery_type.is_active IS '是否启用';
COMMENT ON COLUMN lottery_type.is_visible IS '是否对用户可见';
COMMENT ON COLUMN lottery_type.is_sellable IS '是否可销售';
COMMENT ON COLUMN lottery_type.sales_commission_rate IS '销售佣金比例';
COMMENT ON COLUMN lottery_type.agent_commission_rate IS '代理商佣金比例';
COMMENT ON COLUMN lottery_type.prize_calculation_rule IS '奖金计算规则';
COMMENT ON COLUMN lottery_type.bet_rules IS '投注规则';

-- 添加新字段注释
COMMENT ON COLUMN lottery_type.allow_group_buy IS '是否允许合买';
COMMENT ON COLUMN lottery_type.user_bet_cutoff_advance_minutes IS '用户投注截止时间提前分钟数';
COMMENT ON COLUMN lottery_type.user_min_bet_amount IS '用户投注最低金额';
COMMENT ON COLUMN lottery_type.multi_period_bet_min_amount IS '追期投注最低金额';



-- 创建收款支持方式表
drop table if exists lottery_payment_channel;
CREATE TABLE lottery_payment_channel (
                                         id SERIAL PRIMARY KEY,
                                         channel_code VARCHAR(50) NOT NULL UNIQUE, -- 支付通道唯一编码
                                         channel_name VARCHAR(100) NOT NULL, -- 支付通道名称
                                         channel_type VARCHAR(50) NOT NULL, -- 支付类型（在线支付/银行卡/其他）

    -- 在线支付方式
                                         is_alipay_supported BOOLEAN DEFAULT FALSE, -- 是否支持支付宝
                                         is_wechat_pay_supported BOOLEAN DEFAULT FALSE, -- 是否支持微信支付
                                         is_quick_payment_supported BOOLEAN DEFAULT FALSE, -- 是否支持快捷支付
                                         is_qr_code_payment_supported BOOLEAN DEFAULT FALSE, -- 是否支持二维码收款

    -- 银行卡充值
                                         is_bank_card_recharge_supported BOOLEAN DEFAULT FALSE, -- 是否支持银行卡充值
                                         supported_banks TEXT[], -- 支持的银行列表

    -- 配置信息
                                         min_recharge_amount NUMERIC(10,2) DEFAULT 0.00, -- 最低充值金额
                                         max_recharge_amount NUMERIC(10,2) DEFAULT 1000000.00, -- 最高充值金额
                                         recharge_fee_rate NUMERIC(5,2) DEFAULT 0, -- 充值手续费率
                                         daily_recharge_limit NUMERIC(12,2), -- 每日充值限额

    -- 状态控制
                                         is_active BOOLEAN DEFAULT TRUE, -- 是否启用
                                         is_visible BOOLEAN DEFAULT TRUE, -- 是否对用户可见

    -- 审计字段
                                         created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                         updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 添加表注释
COMMENT ON TABLE lottery_payment_channel IS '彩票系统支付通道配置表';

-- 添加字段注释
COMMENT ON COLUMN lottery_payment_channel.id IS '自增主键';
COMMENT ON COLUMN lottery_payment_channel.channel_code IS '支付通道唯一编码';
COMMENT ON COLUMN lottery_payment_channel.channel_name IS '支付通道名称';
COMMENT ON COLUMN lottery_payment_channel.channel_type IS '支付类型';
COMMENT ON COLUMN lottery_payment_channel.is_alipay_supported IS '是否支持支付宝支付';
COMMENT ON COLUMN lottery_payment_channel.is_wechat_pay_supported IS '是否支持微信支付';
COMMENT ON COLUMN lottery_payment_channel.is_quick_payment_supported IS '是否支持快捷支付';
COMMENT ON COLUMN lottery_payment_channel.is_qr_code_payment_supported IS '是否支持二维码收款';
COMMENT ON COLUMN lottery_payment_channel.is_bank_card_recharge_supported IS '是否支持银行卡充值';
COMMENT ON COLUMN lottery_payment_channel.supported_banks IS '支持的银行列表';
COMMENT ON COLUMN lottery_payment_channel.min_recharge_amount IS '最低充值金额';
COMMENT ON COLUMN lottery_payment_channel.max_recharge_amount IS '最高充值金额';
COMMENT ON COLUMN lottery_payment_channel.recharge_fee_rate IS '充值手续费率';
COMMENT ON COLUMN lottery_payment_channel.daily_recharge_limit IS '每日充值限额';
COMMENT ON COLUMN lottery_payment_channel.is_active IS '是否启用';
COMMENT ON COLUMN lottery_payment_channel.is_visible IS '是否对用户可见';

-- 创建触发器自动更新修改时间
CREATE OR REPLACE FUNCTION update_modified_column()
    RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_lottery_payment_channel_modtime
    BEFORE UPDATE ON lottery_payment_channel
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_column();

-- 创建索引
CREATE INDEX idx_lottery_payment_channel_code ON lottery_payment_channel(channel_code);
CREATE INDEX idx_lottery_payment_channel_type ON lottery_payment_channel(channel_type);
CREATE INDEX idx_lottery_payment_channel_active ON lottery_payment_channel(is_active);

-- 插入一些初始数据示例
INSERT INTO lottery_payment_channel (
    channel_code,
    channel_name,
    channel_type,
    is_alipay_supported,
    is_wechat_pay_supported,
    is_quick_payment_supported,
    is_qr_code_payment_supported,
    is_bank_card_recharge_supported,
    supported_banks
) VALUES
      (
          'ONLINE_PAYMENT_01',
          '主要在线支付通道',
          '在线支付',
          TRUE,   -- 支付宝
          TRUE,   -- 微信支付
          TRUE,   -- 快捷支付
          TRUE,   -- 二维码收款
          FALSE,  -- 银行卡充值
          NULL    -- 银行列表
      ),
      (
          'BANK_RECHARGE_01',
          '银行卡充值通道',
          '银行卡',
          FALSE,  -- 支付宝
          FALSE,  -- 微信支付
          FALSE,  -- 快捷支付
          FALSE,  -- 二维码收款
          TRUE,   -- 银行卡充值
          ARRAY['ICBC', 'ABC', 'BOC', 'CCB', 'CMBC']  -- 支持的银行
      );
-- 彩票方案表
-- 创建彩票方案表
drop table if exists lottery_scheme;
CREATE TABLE lottery_scheme (
                                id SERIAL PRIMARY KEY,
                                scheme_code VARCHAR(100) NOT NULL UNIQUE, -- 方案唯一编码
                                lottery_type_id INTEGER , -- 关联彩种
                                shop_id INTEGER , -- 关联店铺
                                user_id bigint, -- 创建用户

    -- 方案基本信息
                                scheme_name VARCHAR(200), -- 方案名称
                                scheme_type VARCHAR(50) NOT NULL CHECK (scheme_type IN (
                                                                                        'standard', -- 标准方案
                                                                                        'group_buy', -- 合买方案
                                                                                        'chase_number', -- 追号方案
                                                                                        'agent_buy' -- 代购方案
                                    )),

    -- 投注详情
                                bet_numbers TEXT NOT NULL, -- 投注号码
                                bet_count INTEGER NOT NULL, -- 注数
                                multiple INTEGER NOT NULL DEFAULT 1, -- 倍数
                                total_amount NUMERIC(12,2) NOT NULL, -- 总金额

    -- 合买方案额外字段
                                total_shares INTEGER DEFAULT 1, -- 总份数
                                share_price NUMERIC(10,2) DEFAULT 0, -- 每份价格
                                bought_shares INTEGER DEFAULT 0, -- 已购买份数
                                initiator_shares INTEGER DEFAULT 0, -- 发起人认购份数

    -- 追号配置
                                chase_periods INTEGER[] DEFAULT ARRAY[]::INTEGER[], -- 追号期数
                                total_chase_amount NUMERIC(12,2) DEFAULT 0, -- 总追号金额

    -- 状态管理
                                scheme_status VARCHAR(50) NOT NULL DEFAULT 'created' CHECK (scheme_status IN (
                                                                                                              'created', -- 已创建
                                                                                                              'paying', -- 支付中
                                                                                                              'paid', -- 已支付
                                                                                                              'cancelled', -- 已取消
                                                                                                              'winning', -- 中奖
                                                                                                              'settled' -- 已结算
                                    )),

    -- 开奖信息
                                draw_period VARCHAR(50), -- 开奖期号
                                is_win BOOLEAN DEFAULT FALSE, -- 是否中奖
                                win_amount NUMERIC(12,2) DEFAULT 0, -- 中奖金额

    -- 佣金和分成
                                platform_commission NUMERIC(12,2) DEFAULT 0, -- 平台佣金
                                agent_commission NUMERIC(12,2) DEFAULT 0, -- 代理佣金

    -- 合买方案额外管理
                                is_public BOOLEAN DEFAULT FALSE, -- 是否公开方案
                                min_share_count INTEGER DEFAULT 0, -- 最小认购份数

    -- 审计字段
                                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 添加表注释
COMMENT ON TABLE lottery_scheme IS '彩票方案表';

-- 添加字段注释
COMMENT ON COLUMN lottery_scheme.id IS '自增主键';
COMMENT ON COLUMN lottery_scheme.scheme_code IS '方案唯一编码';
COMMENT ON COLUMN lottery_scheme.lottery_type_id IS '彩种ID';
COMMENT ON COLUMN lottery_scheme.shop_id IS '店铺ID';
COMMENT ON COLUMN lottery_scheme.user_id IS '创建用户ID';
COMMENT ON COLUMN lottery_scheme.scheme_name IS '方案名称';
COMMENT ON COLUMN lottery_scheme.scheme_type IS '方案类型';
COMMENT ON COLUMN lottery_scheme.bet_numbers IS '投注号码';
COMMENT ON COLUMN lottery_scheme.bet_count IS '注数';
COMMENT ON COLUMN lottery_scheme.multiple IS '倍数';
COMMENT ON COLUMN lottery_scheme.total_amount IS '总金额';
COMMENT ON COLUMN lottery_scheme.total_shares IS '总份数';
COMMENT ON COLUMN lottery_scheme.share_price IS '每份价格';
COMMENT ON COLUMN lottery_scheme.bought_shares IS '已购买份数';
COMMENT ON COLUMN lottery_scheme.initiator_shares IS '发起人认购份数';
COMMENT ON COLUMN lottery_scheme.chase_periods IS '追号期数';
COMMENT ON COLUMN lottery_scheme.total_chase_amount IS '总追号金额';
COMMENT ON COLUMN lottery_scheme.scheme_status IS '方案状态';
COMMENT ON COLUMN lottery_scheme.draw_period IS '开奖期号';
COMMENT ON COLUMN lottery_scheme.is_win IS '是否中奖';
COMMENT ON COLUMN lottery_scheme.win_amount IS '中奖金额';
COMMENT ON COLUMN lottery_scheme.platform_commission IS '平台佣金';
COMMENT ON COLUMN lottery_scheme.agent_commission IS '代理佣金';
COMMENT ON COLUMN lottery_scheme.is_public IS '是否公开方案';
COMMENT ON COLUMN lottery_scheme.min_share_count IS '最小认购份数';

-- 创建触发器自动更新修改时间
CREATE OR REPLACE FUNCTION update_modified_column()
    RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_lottery_scheme_modtime
    BEFORE UPDATE ON lottery_scheme
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_column();

-- 创建索引
CREATE INDEX idx_lottery_scheme_user_id ON lottery_scheme(user_id);
CREATE INDEX idx_lottery_scheme_lottery_type ON lottery_scheme(lottery_type_id);
CREATE INDEX idx_lottery_scheme_status ON lottery_scheme(scheme_status);
CREATE INDEX idx_lottery_scheme_draw_period ON lottery_scheme(draw_period);

-- 删除已存在的订单表
DROP TABLE IF EXISTS lottery_order;

-- 创建彩票订单表

CREATE TABLE lottery_order (
                               id SERIAL PRIMARY KEY,
                               order_code VARCHAR(100) NOT NULL UNIQUE, -- 订单唯一编码
                               scheme_id INTEGER , -- 关联彩票方案

    -- 订单基本信息
                               lottery_type_id INTEGER, -- 彩种
                               shop_id INTEGER , -- 店铺
                               user_id bigint, -- 下单用户

    -- 订单详情
                               order_type VARCHAR(50) NOT NULL CHECK (order_type IN (
                                                                                     'single_order', -- 单一订单
                                                                                     'group_order', -- 合买订单
                                                                                     'agent_order' -- 代理订单
                                   )),

                               bet_numbers TEXT NOT NULL, -- 投注号码
                               bet_count INTEGER NOT NULL, -- 注数
                               order_multiple INTEGER NOT NULL DEFAULT 1, -- 倍数
                               total_amount NUMERIC(12,2) NOT NULL, -- 订单总金额

    -- 合买订单字段
                               total_shares INTEGER DEFAULT 1, -- 总份数
                               share_price NUMERIC(10,2) DEFAULT 0, -- 每份价格
                               bought_shares INTEGER DEFAULT 0, -- 已购买份数
                               buyer_shares INTEGER DEFAULT 0, -- 购买者认购份数

    -- 订单状态
                               order_status VARCHAR(50) NOT NULL DEFAULT 'created' CHECK (order_status IN (
                                                                                                           'created', -- 已创建
                                                                                                           'paying', -- 支付中
                                                                                                           'paid', -- 已支付
                                                                                                           'cancelled', -- 已取消
                                                                                                           'settled' -- 已结算
                                   )),

    -- 支付信息
                               payment_method VARCHAR(50), -- 支付方式
                               payment_time TIMESTAMP WITH TIME ZONE, -- 支付时间

    -- 开奖信息
                               draw_period VARCHAR(50), -- 开奖期号
                               is_win BOOLEAN DEFAULT FALSE, -- 是否中奖
                               win_amount NUMERIC(12,2) DEFAULT 0, -- 中奖金额

    -- 佣金信息
                               platform_commission NUMERIC(12,2) DEFAULT 0, -- 平台佣金
                               agent_commission NUMERIC(12,2) DEFAULT 0, -- 代理佣金

    -- 其他管理字段
                               is_public BOOLEAN DEFAULT FALSE, -- 是否公开订单
                               min_share_count INTEGER DEFAULT 0, -- 最小认购份数

    -- 审计字段
                               created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                               updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 添加表注释
COMMENT ON TABLE lottery_order IS '彩票订单表';

-- 添加字段注释
COMMENT ON COLUMN lottery_order.id IS '自增主键';
COMMENT ON COLUMN lottery_order.order_code IS '订单唯一编码';
COMMENT ON COLUMN lottery_order.scheme_id IS '关联彩票方案ID';
COMMENT ON COLUMN lottery_order.lottery_type_id IS '彩种ID';
COMMENT ON COLUMN lottery_order.shop_id IS '店铺ID';
COMMENT ON COLUMN lottery_order.user_id IS '下单用户ID';
COMMENT ON COLUMN lottery_order.order_type IS '订单类型';
COMMENT ON COLUMN lottery_order.bet_numbers IS '投注号码';
COMMENT ON COLUMN lottery_order.bet_count IS '注数';
COMMENT ON COLUMN lottery_order.order_multiple IS '倍数';
COMMENT ON COLUMN lottery_order.total_amount IS '订单总金额';
COMMENT ON COLUMN lottery_order.total_shares IS '总份数';
COMMENT ON COLUMN lottery_order.share_price IS '每份价格';
COMMENT ON COLUMN lottery_order.bought_shares IS '已购买份数';
COMMENT ON COLUMN lottery_order.buyer_shares IS '购买者认购份数';
COMMENT ON COLUMN lottery_order.order_status IS '订单状态';
COMMENT ON COLUMN lottery_order.payment_method IS '支付方式';
COMMENT ON COLUMN lottery_order.payment_time IS '支付时间';
COMMENT ON COLUMN lottery_order.draw_period IS '开奖期号';
COMMENT ON COLUMN lottery_order.is_win IS '是否中奖';
COMMENT ON COLUMN lottery_order.win_amount IS '中奖金额';
COMMENT ON COLUMN lottery_order.platform_commission IS '平台佣金';
COMMENT ON COLUMN lottery_order.agent_commission IS '代理佣金';
COMMENT ON COLUMN lottery_order.is_public IS '是否公开订单';
COMMENT ON COLUMN lottery_order.min_share_count IS '最小认购份数';

-- 创建触发器自动更新修改时间
CREATE OR REPLACE FUNCTION update_modified_column()
    RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_lottery_order_modtime
    BEFORE UPDATE ON lottery_order
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_column();

-- 创建索引
CREATE INDEX idx_lottery_order_user_id ON lottery_order(user_id);
CREATE INDEX idx_lottery_order_lottery_type ON lottery_order(lottery_type_id);
CREATE INDEX idx_lottery_order_status ON lottery_order(order_status);
CREATE INDEX idx_lottery_order_draw_period ON lottery_order(draw_period);


-- 删除已存在的投注记录表
DROP TABLE IF EXISTS lottery_bet_record;

-- 创建彩票投注记录表
CREATE TABLE lottery_bet_record (
                                    id SERIAL PRIMARY KEY,
                                    bet_record_code VARCHAR(100) NOT NULL UNIQUE, -- 投注记录唯一编码
                                    order_id INTEGER , -- 关联订单
                                    scheme_id INTEGER , -- 关联方案

    -- 基本投注信息
                                    lottery_type_id INTEGER NOT NULL, -- 彩种
                                    user_id INTEGER  , -- 投注用户
                                    shop_id INTEGER , -- 投注店铺

    -- 投注详情
                                    bet_type VARCHAR(50) NOT NULL CHECK (bet_type IN (
                                                                                      'single', -- 单式
                                                                                      'multiple', -- 复式
                                                                                      'group', -- 组选
                                                                                      'package', -- 包号
                                                                                      'combination' -- 机选
                                        )),
                                    bet_method VARCHAR(50) NOT NULL CHECK (bet_method IN (
                                                                                          'normal', -- 普通投注
                                                                                          'chase', -- 追号
                                                                                          'joint' -- 合买
                                        )),

    -- 具体投注号码
                                    bet_numbers TEXT NOT NULL, -- 投注号码
                                    bet_numbers_type VARCHAR(50), -- 号码类型（如大小单双）

    -- 投注计算
                                    bet_count INTEGER NOT NULL, -- 注数
                                    bet_multiple INTEGER NOT NULL DEFAULT 1, -- 倍数
                                    single_bet_amount NUMERIC(10,2) NOT NULL, -- 单注金额
                                    total_bet_amount NUMERIC(12,2) NOT NULL, -- 总投注金额

    -- 开奖信息
                                    draw_period VARCHAR(50), -- 开奖期号
                                    draw_time TIMESTAMP WITH TIME ZONE, -- 开奖时间
                                    is_win BOOLEAN DEFAULT FALSE, -- 是否中奖
                                    win_amount NUMERIC(12,2) DEFAULT 0, -- 中奖金额
                                    win_level VARCHAR(50), -- 中奖等级

    -- 状态管理
                                    bet_status VARCHAR(50) NOT NULL DEFAULT 'created' CHECK (bet_status IN (
                                                                                                            'created', -- 已创建
                                                                                                            'confirmed', -- 已确认
                                                                                                            'canceled', -- 已取消
                                                                                                            'waiting_draw', -- 等待开奖
                                                                                                            'drawn', -- 已开奖
                                                                                                            'settled' -- 已结算
                                        )),

    -- 追号相关
                                    is_chase_bet BOOLEAN DEFAULT FALSE, -- 是否追号
                                    chase_total_periods INTEGER DEFAULT 1, -- 追号总期数
                                    current_chase_period INTEGER DEFAULT 1, -- 当前追号期数

    -- 佣金信息
                                    platform_commission NUMERIC(10,2) DEFAULT 0, -- 平台佣金
                                    agent_commission NUMERIC(10,2) DEFAULT 0, -- 代理佣金

    -- 审计字段
                                    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 添加表注释
COMMENT ON TABLE lottery_bet_record IS '彩票投注记录表';

-- 添加字段注释
COMMENT ON COLUMN lottery_bet_record.id IS '自增主键';
COMMENT ON COLUMN lottery_bet_record.bet_record_code IS '投注记录唯一编码';
COMMENT ON COLUMN lottery_bet_record.order_id IS '关联订单ID';
COMMENT ON COLUMN lottery_bet_record.scheme_id IS '关联方案ID';
COMMENT ON COLUMN lottery_bet_record.lottery_type_id IS '彩种ID';
COMMENT ON COLUMN lottery_bet_record.user_id IS '投注用户ID';
COMMENT ON COLUMN lottery_bet_record.shop_id IS '投注店铺ID';
COMMENT ON COLUMN lottery_bet_record.bet_type IS '投注类型';
COMMENT ON COLUMN lottery_bet_record.bet_method IS '投注方式';
COMMENT ON COLUMN lottery_bet_record.bet_numbers IS '投注号码';
COMMENT ON COLUMN lottery_bet_record.bet_numbers_type IS '号码类型';
COMMENT ON COLUMN lottery_bet_record.bet_count IS '注数';
COMMENT ON COLUMN lottery_bet_record.bet_multiple IS '倍数';
COMMENT ON COLUMN lottery_bet_record.single_bet_amount IS '单注金额';
COMMENT ON COLUMN lottery_bet_record.total_bet_amount IS '总投注金额';
COMMENT ON COLUMN lottery_bet_record.draw_period IS '开奖期号';
COMMENT ON COLUMN lottery_bet_record.draw_time IS '开奖时间';
COMMENT ON COLUMN lottery_bet_record.is_win IS '是否中奖';
COMMENT ON COLUMN lottery_bet_record.win_amount IS '中奖金额';
COMMENT ON COLUMN lottery_bet_record.win_level IS '中奖等级';
COMMENT ON COLUMN lottery_bet_record.bet_status IS '投注状态';
COMMENT ON COLUMN lottery_bet_record.is_chase_bet IS '是否追号';
COMMENT ON COLUMN lottery_bet_record.chase_total_periods IS '追号总期数';
COMMENT ON COLUMN lottery_bet_record.current_chase_period IS '当前追号期数';
COMMENT ON COLUMN lottery_bet_record.platform_commission IS '平台佣金';
COMMENT ON COLUMN lottery_bet_record.agent_commission IS '代理佣金';

-- 创建触发器自动更新修改时间
CREATE OR REPLACE FUNCTION update_modified_column()
    RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_lottery_bet_record_modtime
    BEFORE UPDATE ON lottery_bet_record
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_column();

-- 创建索引
CREATE INDEX idx_lottery_bet_record_user_id ON lottery_bet_record(user_id);
CREATE INDEX idx_lottery_bet_record_order_id ON lottery_bet_record(order_id);
CREATE INDEX idx_lottery_bet_record_lottery_type ON lottery_bet_record(lottery_type_id);
CREATE INDEX idx_lottery_bet_record_draw_period ON lottery_bet_record(draw_period);
CREATE INDEX idx_lottery_bet_record_status ON lottery_bet_record(bet_status);
--  横幅
drop table if EXISTS banners;
CREATE TABLE banners (
                         id SERIAL PRIMARY KEY,
                         title VARCHAR(255),
                         image_url TEXT,
                         link_url TEXT,
                         start_time TIMESTAMP,
                         end_time TIMESTAMP,
                         status BOOLEAN DEFAULT TRUE
);
-- 插屏弹框
CREATE TABLE popups (
                        id SERIAL PRIMARY KEY,
                        content TEXT,
                        start_time TIMESTAMP,
                        end_time TIMESTAMP,
                        status BOOLEAN DEFAULT TRUE
);
-- 广播
CREATE TABLE broadcasts (
                            id SERIAL PRIMARY KEY,
                            message TEXT,
                            created_at TIMESTAMP DEFAULT NOW()
);
-- 投注
CREATE TABLE bet_options (
                             id SERIAL PRIMARY KEY,
                             type VARCHAR(50),
                             match_id BIGINT,
                             odds DECIMAL(10, 2),
                             status BOOLEAN DEFAULT TRUE
);
-- 跟单
CREATE TABLE follow_orders (
                               id SERIAL PRIMARY KEY,
                               user_id BIGINT,
                               match_id BIGINT,
                               bet_amount DECIMAL(10, 2),
                               potential_win DECIMAL(10, 2),
                               created_at TIMESTAMP DEFAULT NOW()
);
-- 钱包相关
CREATE TABLE transactions (
                              id SERIAL PRIMARY KEY,
                              wallet_id BIGINT REFERENCES wallets(id),
                              type VARCHAR(50), -- deposit, withdrawal, transfer
                              amount DECIMAL(10, 2),
                              created_at TIMESTAMP DEFAULT NOW()
);
-- 排名表
CREATE TABLE rankings (
                          id SERIAL PRIMARY KEY,
                          type VARCHAR(50), -- 投注、中奖、推广
                          user_id BIGINT REFERENCES users(id),
                          rank INT,
                          score DECIMAL(10, 2),
                          created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE lottery_results (
                                 id SERIAL PRIMARY KEY,
                                 lottery_type VARCHAR(50) NOT NULL,   -- 彩票类型，如 "大乐透", "双色球"
                                 draw_date DATE NOT NULL,             -- 开奖日期
                                 source VARCHAR(100) NOT NULL,        -- 数据来源
                                 result JSONB NOT NULL,               -- 彩票结果，JSON 格式存储
                                 received_at TIMESTAMP DEFAULT NOW(), -- 数据接收时间
                                 UNIQUE (lottery_type, draw_date, source)
);
CREATE TABLE final_lottery_results (
                                       id SERIAL PRIMARY KEY,
                                       lottery_type VARCHAR(50) NOT NULL,
                                       draw_date DATE NOT NULL,
                                       result JSONB NOT NULL,                -- 最终彩票结果
                                       verified_sources JSONB NOT NULL,     -- 参与验证的数据来源
                                       conflicts JSONB,                     -- 冲突来源记录
                                       finalized_at TIMESTAMP DEFAULT NOW()
);
-- 数据源 → 数据收集模块 (存入 lottery_results 表) → 数据对比与验证模块 → 冲突处理 (人工干预) →
-- 结果确认 (存入 final_lottery_results 表) → 前端展示模块
-- 自动追号：设置连续购买的期数。
-- 停追条件：如中奖停止追号。
