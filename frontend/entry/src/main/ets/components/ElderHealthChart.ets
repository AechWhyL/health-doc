import { HealthMeasurement, HealthDataType } from './DailyHealthDataView';
import { VChart } from '@visactor/harmony-vchart';
import { JSON } from '@kit.ArkTS';

interface ChartDataPoint {
  date: string;
  type: string;
  value: number;
}

@Component
export struct ElderHealthChart {
  @Prop @Watch('onDataChange') healthRecords: HealthMeasurement[] = [];
  @Prop @Watch('onDataChange') selectedType: HealthDataType = 'bp';

  // VChart spec state
  @State chartSpec: Object|null = null;
  
  aboutToAppear() {
    this.updateChartSpec();
  }

  onDataChange() {
    this.updateChartSpec();
  }

  private formatDate(dateStr: string): string {
    const d = new Date(dateStr);
    return `${d.getMonth() + 1}/${d.getDate()}`;
  }

  private updateChartSpec() {
    const data: ChartDataPoint[] = [];
    
    // Sort records by date (ascending for chart)
    const sortedRecords = [...this.healthRecords].sort((a, b) => 
      new Date(a.measured_at).getTime() - new Date(b.measured_at).getTime()
    );

    // Transform data based on selected type
    sortedRecords.forEach(record => {
      const dateStr = this.formatDate(record.measured_at);
      
      if (this.selectedType === 'bp') {
        if (record.sbp !== undefined) {
          data.push({ date: dateStr, type: '收缩压', value: Number(record.sbp) });
        }
        if (record.dbp !== undefined) {
          data.push({ date: dateStr, type: '舒张压', value: Number(record.dbp) });
        }
      } else if (this.selectedType === 'fpg') {
        if (record.fpg !== undefined) {
          data.push({ date: dateStr, type: '空腹血糖', value: Number(record.fpg) });
        }
        if (record.ppg_2h !== undefined) {
          data.push({ date: dateStr, type: '餐后2h血糖', value: Number(record.ppg_2h) });
        }
      } else if (this.selectedType === 'weight') {
        if (record.weight !== undefined) {
          data.push({ date: dateStr, type: '体重', value: Number(record.weight) });
        }
      }
    });

    // Define colors based on type
    const colors = this.selectedType === 'bp' 
      ? ['#ef4444', '#3b82f6'] // Red (High), Blue (Low)
      : this.selectedType === 'fpg'
      ? ['#10b981', '#f59e0b'] // Green (Fasting), Orange (Post-prandial)
      : ['#6366f1']; // Indigo (Weight)

    // specific JSON string construction
    // Use JSON.stringify for complex objects (data, colors) to ensure valid JSON
    const dataStr = JSON.stringify(data);
    const colorStr = JSON.stringify(colors);

    console.log('[Health Chart] dataStr:' + dataStr)

    const specString = `
      {
        "type": "line",
        "data": [
          {
            "id": "healthData",
            "values": ${dataStr}
          }
        ],
        "xField": "date",
        "yField": "value",
        "seriesField": "type",
        "color": ${colorStr},
        "legends": {
          "visible": true,
          "orient": "bottom",
          "position": "start",
          "padding": { "top": 10 }
        },
        "axes": [
          {
            "orient": "left",
            "label": {
              "style": {
                "fill": "#64748b"
              }
            }
          },
          {
            "orient": "bottom",
            "label": {
              "style": {
                "fill": "#64748b"
              }
            }
          }
        ],
        "point": {
          "style": {
            "size": 8,
            "stroke": "#ffffff",
            "lineWidth": 2
          }
        },
        "line": {
          "style": {
            "lineWidth": 3
          }
        },
        "tooltip": {
          "visible": true,
          "renderMode": "canvas"
        }
      }
    `;

    this.chartSpec = JSON.parse(specString);
  }

  build() {
    Column() {
      if (this.healthRecords.length > 0) {

        if(this.selectedType === "weight"){
          // VChart Component
          VChart({
            spec: this.chartSpec,
            w: 360,
            h: 220,
          })
            .margin({ top: 10, bottom: 10 })
        }

        if(this.selectedType === "bp"){
          // VChart Component
          VChart({
            spec: this.chartSpec,
            w: 360,
            h: 220,
          })
            .margin({ top: 10, bottom: 10 })
        }

        if(this.selectedType === "fpg"){
          // VChart Component
          VChart({
            spec: this.chartSpec,
            w: 360,
            h: 220,
          })
            .margin({ top: 10, bottom: 10 })
        }

      } else {
        // Empty state for chart area (optional, parent handles main empty state)
        Column()
          .height(0)
      }
    }
    .width('100%')
    .padding({ left: 10, right: 10 })
    .backgroundColor('#ffffff')
    .borderRadius(12)
  }
}
