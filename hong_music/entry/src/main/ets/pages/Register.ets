import router from '@ohos.router'
import { promptAction } from '@kit.ArkUI'
import { DARK_MODE_KEY } from '../constants'
export class user{
  id:number = 1
  username:string = ''
  phone: string = ''
  photo: string = ''
  gender: string = ''
  password:string = ''
}
@Entry
@Component
struct Register {
  @State user: user = new user()
  @State isGreen: boolean = true
  @State isLoading: boolean = false
  @State password1:string = ''
  @StorageLink(DARK_MODE_KEY)
  darkMode: boolean = true
  aboutToAppear() {
    this.user.phone = ''
    this.user.username = ''
    this.user.gender = ''
    this.user.password = ''
    this.isGreen = false
  }
  build() {
    Column() {
      Column({ space: 15 }) {
        Text('注册')
          .fontSize(25)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.darkMode ? Color.White : Color.Black)
        Text('欢迎注册')
          .fontSize(16)
          .fontColor(this.darkMode ? '#AAAAAA' : '#666666')
      }
      .width('100%')
      .height(200)
      .justifyContent(FlexAlign.End)
      .alignItems(HorizontalAlign.Start)
      .padding(20)
      .margin({ bottom: 30 })
      Column({ space: 10 }) {

        Row({ space: 10 }) {
          Image($r('app.media.phone'))
            .width(25)
            .height(25)
          Row() {}
          .width(1)
          .height(25)
          .backgroundColor('#000')
          .opacity(0.2)
          TextInput({ text: this.user.username, placeholder: '请输入用户名' })
            .maxLength(15)
            .copyOption(CopyOptions.LocalDevice)
            .layoutWeight(1)
            .height(50)
            .backgroundColor(Color.Transparent)
            .borderRadius(0)
            .padding(0)
            .onChange(value => this.user.username = value)
        }
        .width('100%')
        .height(50)
        .backgroundColor(this.darkMode ? '#2A2A2A' : '#FFFFFF')
        .borderRadius(15)
        .padding({ left: 15, right: 15 })

        /* 手机号 */
        Row({ space: 10 }) {
          Image($r('app.media.phone'))
            .width(25)
            .height(25)
          Row() {}
          .width(1)
          .height(25)
          .backgroundColor('#000')
          .opacity(0.2)
          TextInput({ text: this.user.phone, placeholder: '请输入手机号' })
            .maxLength(15)
            .copyOption(CopyOptions.LocalDevice)
            .layoutWeight(1)
            .height(50)
            .backgroundColor(Color.Transparent)
            .borderRadius(0)
            .padding(0)
            .onChange(value => this.user.phone = value)
        }
        .width('100%')
        .height(50)
        .backgroundColor(this.darkMode ? '#2A2A2A' : '#FFFFFF')
        .borderRadius(15)
        .padding({ left: 15, right: 15 })
        .margin({ top: 10 })

        // 密码
        Row({ space: 10 }) {
          Image($r('app.media.code'))
            .width(25)
            .height(25)
          Row() {}
          .width(1)
          .height(25)
          .backgroundColor('#000')
          .opacity(0.2)
          TextInput({ text: `${this.user.password}`, placeholder: '请输入密码' })
            .maxLength(15)
            .type(InputType.Password)
            .copyOption(CopyOptions.LocalDevice)
            .layoutWeight(1)
            .height(50)
            .backgroundColor(Color.Transparent)
            .borderRadius(0)
            .padding(0)
            .onChange(value => this.user.password = value)
        }
        .width('100%')
        .height(50)
        .backgroundColor(this.darkMode ? '#2A2A2A' : '#FFFFFF')
        .borderRadius(15)
        .padding({ left: 15, right: 15 })
        .margin({ top: 10 })

        // 再次输入密码
        Row({ space: 10 }) {
          Image($r('app.media.code'))
            .width(25)
            .height(25)
          Row() {}
          .width(1)
          .height(25)
          .backgroundColor('#000')
          .opacity(0.2)
          TextInput({ text: `${this.password1}`, placeholder: '请再次输入密码' })
            .maxLength(15)
            .type(InputType.Password)
            .copyOption(CopyOptions.LocalDevice)
            .layoutWeight(1)
            .height(50)
            .backgroundColor(Color.Transparent)
            .borderRadius(0)
            .padding(0)
            .onChange(value => this.password1 = value)
        }
        .width('100%')
        .height(50)
        .backgroundColor(this.darkMode ? '#2A2A2A' : '#FFFFFF')
        .borderRadius(15)
        .padding({ left: 15, right: 15 })
        .margin({ top: 10 })

        Row({ space: 10 }) {
          Image($r('app.media.code'))
            .width(25)
            .height(25)
          Row() {}
          .width(1)
          .height(25)
          .backgroundColor('#000')
          .opacity(0.2)
          TextInput({ text: `${this.user.gender}`, placeholder: '请输入性别' })
            .maxLength(15)
            .copyOption(CopyOptions.LocalDevice)
            .layoutWeight(1)
            .height(50)
            .backgroundColor(Color.Transparent)
            .borderRadius(0)
            .padding(0)
            .onChange(value => this.user.gender = value)
        }
        .width('100%')
        .height(50)
        .backgroundColor(this.darkMode ? '#2A2A2A' : '#FFFFFF')
        .borderRadius(15)
        .padding({ left: 15, right: 15 })
        .margin({ top: 10 })





        Row() {
          Checkbox()
            .width(13)
            .height(13)
            .select(this.isGreen)
            .onChange(value => this.isGreen = value)
          Text('我已阅读并同意')
            .fontSize(12)
            .fontColor('#9C9BAB')
          Text('《用户注册服务条款》')
            .fontSize(12)
            .fontColor('#2974C8')
          Text('与')
            .fontSize(12)
            .fontColor('#9C9BAB')
          Text('《隐私政策》')
            .fontSize(12)
            .fontColor('#2974C8')
        }
        .width('100%')
        .margin({ top: 20 })
        /* 注册按钮 */
        Button('注册')
          .width('100%')
          .backgroundColor('#5677FC')
          .onClick(async () => {
            const regex = /^(13[0-9]|14[01456879]|15[0-35-9]|16[2567]|17[0-8]|18[0-9]|19[0-35-9])\d{8}$/
            if(this.user.phone === '' || !regex.test(this.user.phone)) {
              promptAction.showToast({message:'手机号不合法'})
              return
            }
            if(this.user.password === '') {
              promptAction.showToast({message:'密码不能为空'})
              return
            }
            if(this.password1 === '') {
              promptAction.showToast({message:'请再次输入密码'})
              return
            }
            if(this.user.password !== this.password1) {
              promptAction.showToast({message:'密码输入不一致'})
              return
            }
            if(this.isGreen === false) {
              promptAction.showToast({message:'请先同意条款'})
              return
            }
            promptAction.showToast({message:'注册成功'})
            setTimeout(() => {
              router.pushUrl({
                url: 'pages/Login'
              })
            }, 2000)
          })
        Text('返回登录')
          .fontSize(15)
          .opacity(0.8)
          .margin({ top: 10 })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/Login'
            })
          })
        if(this.isLoading === true) {
          LoadingProgress()
            .color(Color.Gray)
            .width(60)
            .height(60)
            .margin({ top: 30, bottom: 30 })
        }
      }
      .width('100%')
      .padding({ left: 25, right: 25 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.darkMode ? '#3c3f41' : '#F2F5F9')
  }
}
