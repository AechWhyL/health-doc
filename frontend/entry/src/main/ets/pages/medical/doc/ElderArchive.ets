import { promptAction } from '@kit.ArkUI';
import dayjs from 'dayjs';
import { HealthRecordDetailDialog } from '../../../components/medical/HealthRecordDetailDialog';
import {
  HealthRecordItem,
  ElderBasicInfo
} from '../../../models/HealthArchiveModels';
import { ElderInfoEditRouteParams } from '../../common/ElderInfoEditPage';
import { httpRequest } from '../../../common/api/HttpUtil';
import { RequestEnum } from '../../../common/api/httpEnum';

interface ApiResponse<T = Object> {
  code: number;
  message: string;
  data?: T;
  timestamp: number;
}

@Builder
export function ElderArchiveBuilder() {
  ElderArchive()
}

@ComponentV2
export struct ElderArchive {
  @Local private elder: ElderBasicInfo | null = null;
  @Local private viewingRecord: HealthRecordItem | null = null;
  @Local private isLoading: boolean = false;

  navPathStack: NavPathStack = new NavPathStack();
  private detailDialogController: CustomDialogController | null = null;
  private elderId: number = 0;

  private formatBirthDate(dateStr: string): string {
    if (!dateStr) return '未填写';
    return dayjs(dateStr).format('YYYY年M月D日');
  }

  private getGenderEmoji(gender: number): string {
    return gender === 1 ? '👴' : '👵';
  }

  private getGenderText(gender: number): string {
    return gender === 1 ? '男' : '女';
  }

  private async loadElderInfo(): Promise<void> {
    if (!this.elderId) return;

    this.isLoading = true;

    try {
      const response = await httpRequest<ApiResponse<ElderBasicInfo>, void>({
        url: `/api/v1/elder-health/elder/${this.elderId}`,
        method: RequestEnum.GET
      });

      if (response.code === 200 && response.data) {
        this.elder = response.data;
      } else {
        promptAction.showToast({ message: response.message || '加载失败' });
      }
    } catch (error) {
      console.error('加载老人信息失败:', error);
      promptAction.showToast({ message: '网络异常' });
    } finally {
      this.isLoading = false;
    }
  }

  private openHealthRecordListPage(): void {
    if (!this.elder) return;

    this.navPathStack.pushPath({
      name: 'Medical_HealthRecordList',
      param: this.elder
    });
  }

  private openElderInfoEditPage(): void {
    if (!this.elder) return;

    const params: ElderInfoEditRouteParams = {
      elderId: this.elder.id
    };
    this.navPathStack.pushPathByName('Common_ElderInfoEdit', params as object);
  }

  @Builder
  private InfoRow(icon: string, label: string, value: string) {
    Row() {
      Text(icon + ' ' + label)
        .fontSize(13)
        .fontColor('#64748b')
        .width(120)
      Text(value)
        .fontSize(14)
        .fontColor('#1e293b')
        .layoutWeight(1)
    }
    .width('100%')
    .padding({ top: 10, bottom: 10 })
  }

  @Builder
  buildElderInfoCard() {
    if (this.elder) {
      Column() {
        // Title row with edit button
        Row() {
          Text('基本信息')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1e293b')
            .layoutWeight(1)

          Row() {
            Text('✏️')
              .fontSize(16)
              .margin({ right: 4 })
            Text('编辑')
              .fontSize(14)
              .fontColor('#2563eb')
          }
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor('#eff6ff')
          .borderRadius(8)
          .onClick(() => {
            this.openElderInfoEditPage();
          })
        }
        .width('100%')
        .margin({ bottom: 16 })

        // Header with avatar and basic info
        Row() {
          Column() {
            Text(this.getGenderEmoji(this.elder.gender))
              .fontSize(40)
          }
          .width(72)
          .height(72)
          .borderRadius(36)
          .backgroundColor('#f1f5f9')
          .justifyContent(FlexAlign.Center)

          Column() {
            Text(this.elder.name)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1e293b')
            Text(this.getGenderText(this.elder.gender) + ' · ' + this.elder.age + '岁')
              .fontSize(14)
              .fontColor('#64748b')
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 16 })
        }
        .width('100%')

        // Detailed info
        Column() {
          this.InfoRow('📱', '电话', this.elder.phone)
          this.InfoRow('🎂', '出生日期', this.formatBirthDate(this.elder.birth_date))
          this.InfoRow('📍', '地址', this.elder.address || '未填写')
          this.InfoRow('🆘', '紧急联系人', this.elder.emergency_contact || '未填写')
          if (this.elder.blood_type) {
            this.InfoRow('🩸', '血型', this.elder.blood_type)
          }
          if (this.elder.height) {
            this.InfoRow('📏', '身高', this.elder.height + ' cm')
          }
          if (this.elder.weight) {
            this.InfoRow('⚖️', '体重', this.elder.weight + ' kg')
          }
        }
        .margin({ top: 20 })
        .padding(16)
        .backgroundColor('#f8fafc')
        .borderRadius(12)
        .width('100%')
      }
      .width('100%')
      .padding(20)
      .backgroundColor(Color.White)
      .borderRadius(16)
      .shadow({ radius: 8, color: '#0f172a10', offsetY: 2 })
    }
  }

  @Builder
  buildHealthRecordEntryCard() {
    Column() {
      Row() {
        Column() {
          Text('📋')
            .fontSize(32)
        }
        .width(56)
        .height(56)
        .borderRadius(28)
        .backgroundColor('#eff6ff')
        .justifyContent(FlexAlign.Center)

        Column() {
          Text('健康档案')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1e293b')
          Text('查看病史、检查报告、用药记录等')
            .fontSize(13)
            .fontColor('#64748b')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 16 })

        Text('›')
          .fontSize(28)
          .fontColor('#cbd5e1')
      }
      .width('100%')
      .padding(20)
      .backgroundColor(Color.White)
      .borderRadius(16)
      .shadow({ radius: 8, color: '#0f172a10', offsetY: 2 })
      .onClick(() => {
        this.openHealthRecordListPage();
      })
    }
    .width('100%')
  }

  build() {
    Column() {
      NavDestination() {
        if (this.isLoading) {
          Column() {
            LoadingProgress().width(40).height(40).color('#2563eb')
            Text('加载中...').fontSize(14).fontColor('#64748b').margin({ top: 12 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#f1f5f9')
        } else {
          Scroll() {
            Column() {
              // Elder info card
              this.buildElderInfoCard()

              Blank(20)

              // Health record entry card
              this.buildHealthRecordEntryCard()

              Column().height(20)
            }
            .padding({ left: 16, right: 16, top: 16, bottom: 16 })
            .constraintSize({
              minHeight: "100%"
            })
          }
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .backgroundColor('#f1f5f9')
        }
      }
      .title('老人详情')
      .onReady((ctx: NavDestinationContext) => {
        this.navPathStack = ctx.pathStack;
        const param = ctx.pathInfo.param as ElderBasicInfo;
        if (param && param.id) {
          this.elderId = param.id;
          this.elder = param;
        }
      })
      .onShown(() => {
        // 页面显示时刷新数据
        this.loadElderInfo();
      })
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#f1f5f9')
    }
  }
}
