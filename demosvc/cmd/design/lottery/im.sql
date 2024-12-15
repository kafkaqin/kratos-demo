CREATE TABLE user (
                                    id SERIAL PRIMARY KEY,
                                    username VARCHAR(100) NOT NULL UNIQUE,
                                    password VARCHAR(100) NOT NULL
);

CREATE TABLE friendship (
                      friendship_id SERIAL PRIMARY KEY,
                      use_id int,
                      friend_id int,
                    status varchar(255)
);

CREATE TABLE group (
                            group_id SERIAL PRIMARY KEY,
                            group_name varchar,
                            creator_id int
);

CREATE TABLE group_members (
                       group_members_id SERIAL PRIMARY KEY,
                       group_id varchar,
                       user_id int
);

CREATE TABLE message (
                       message_id SERIAL PRIMARY KEY,
                       content varchar,
                       sender_id int,
                       receiver_id int,
    send_time timestamp,
    message_type varchar, (image url)
                       is_read int,
    status int , -- 已撤回 已删除 正常
    priority int ,
    source varchar,
    reference_message_id int,
    encrypted int,
    expiration_time timestamp,
    cluster_id varchar(50),
    partition_key varchar(50),
    sequence_number int,
    send_time_month varchar,
    send_time_year character
);

CREATE TABLE message_status (
                                message_status_id SERIAL PRIMARY KEY,
                         message_id int,
                         is_read int

);
CREATE TABLE conversations (
                               id SERIAL PRIMARY KEY,              -- 会话ID
                               user_id INT NOT NULL,               -- 用户ID，表示某个用户参与的会话
                               conversation_id VARCHAR(255) NOT NULL, -- 会话唯一标识
                               conversation_type VARCHAR(50),        -- 会话类型，例如 'private', 'group', 'customer_service'
                               participants TEXT[],                 -- 参与者ID列表
                               last_message_id INT,                 -- 最新消息ID
                               unread_count INT DEFAULT 0,          -- 未读消息数量
                               status VARCHAR(50) DEFAULT 'active', -- 会话状态（例如：'active', 'archived', 'deleted'）
                               created_at TIMESTAMP DEFAULT NOW(),  -- 创建时间
                               updated_at TIMESTAMP DEFAULT NOW(),  -- 更新时间
                               FOREIGN KEY (last_message_id) REFERENCES messages(id)  -- 关联最后一条消息
);

-- CREATE TABLE messages (
--                           id SERIAL PRIMARY KEY,               -- 消息ID
--                           conversation_id VARCHAR(255) NOT NULL, -- 会话ID
--                           sender_id INT NOT NULL,              -- 发送者ID
--                           content TEXT,                        -- 消息内容
--                           message_type VARCHAR(50),            -- 消息类型（如文本、图片、视频等）
--                           sent_at TIMESTAMP DEFAULT NOW(),     -- 消息发送时间
--                           is_read BOOLEAN DEFAULT FALSE,       -- 是否已读
--                           FOREIGN KEY (conversation_id) REFERENCES conversations(conversation_id)
-- );
    -- https://github.com/openimsdk/open-im-server



-- local cache / remote cache 最近联系人的消息列表和未读消息
-- 最近联系人的消息列表和未读消息
-- Timeline 客户端缓存

CREATE TABLE customer_service (
                               id SERIAL PRIMARY KEY,
                               service_id INT NOT NULL,
                               service_name VARCHAR(255) NOT NULL,
                               skills text,
                               status  int,
                               created_at TIMESTAMP DEFAULT NOW(),
                               updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE service_assignments (
                                  assignment_id SERIAL PRIMARY KEY,
                                  service_id INT NOT NULL,
                                  assignment_at TIMESTAMP DEFAULT NOW()
);

-- 合作店铺
-- 派单店铺
-- 出票店铺的区别
-- 一个人
-- 平台用户
-- 员工可以推荐人吗
-- 支持邮箱登录吗
-- 会员等级
--
-- 推荐code生成规则: AES加密 然后加随机字符串 ,随机字符串需要存储在数据库中(mongodb中也行)
--
-- 要分库分表
-- 店铺表
-- 版本管理
--
--
-- 平滑消息 如何销锋
-- 存储热点消息数据
-- 回话列表：userid:session value:sessionid(hash )
-- unread:user_id:session_id  count
--
-- client--->nats---websocket-->消息存储
-- 消息发送  消息推送  消息存储
-- session_id= client 一个客户端对应很多消息会话 群消息 好有消息 客服消息
-- 消息会话
-- 设备端要实现Timeline  session_timeline
-- 批量插入数据
-- 敏感词过滤
-- 个人聊天 群聊 客户(分数据库) 分表(时间加群主 时间加个人 时间加客户(message_2024_12_friend))
--
-- 会话 id
--
-- IM中客服分配功能
-- (接入层 逻辑层 存储层)
--
-- user_id:
-- group_id
--
-- 热点消息使用list
-- IM进入聊天弹窗
-- unread_private_message_id user123 recoiver_id 3


-- 1.合作店铺 派单店铺 出票店铺的区别？
-- 2.员工可以推荐人吗
-- 3.支持邮箱登录吗
-- 4.敏感词过滤
--   个人聊天
--    群聊
--    客服
-- 直播聊天弹窗
-- 未读消息
-- IM中客服分配功能
-- 直播二维码