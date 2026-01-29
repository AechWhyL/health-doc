import { Database } from '../src/config/database';

async function createTable() {
    const sql = `
    CREATE TABLE IF NOT EXISTS \`health_record_history\` (
      \`id\` INT NOT NULL AUTO_INCREMENT,
      \`health_record_id\` INT NOT NULL COMMENT '关联的健康档案ID',
      \`operator_id\` INT NOT NULL COMMENT '操作人ID',
      \`operation_type\` VARCHAR(20) NOT NULL COMMENT '操作类型: ADD, MODIFY',
      \`snapshot_before\` JSON NULL COMMENT '操作前快照 (新增操作为NULL)',
      \`snapshot_after\` JSON NOT NULL COMMENT '操作后快照',
      \`created_at\` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (\`id\`),
      INDEX \`idx_health_record_id\` (\`health_record_id\`),
      INDEX \`idx_operator_id\` (\`operator_id\`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='健康档案操作历史表';
  `;

    try {
        console.log('Creating health_record_history table...');
        await Database.query(sql);
        console.log('Table created successfully.');
        process.exit(0);
    } catch (error) {
        console.error('Error creating table:', error);
        process.exit(1);
    }
}

createTable();
