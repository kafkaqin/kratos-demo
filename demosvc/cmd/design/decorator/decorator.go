package main

import "fmt"

type Payment interface {
	Pay(amount float64) string
}

type CreditCardPayment struct{}

func (c *CreditCardPayment) Pay(amount float64) string {
	return fmt.Sprintf("Paid %.2f using Credit Card", amount)
}

// PaymentDecorator 是装饰器的基础类型，持有一个 Payment 实例
type PaymentDecorator struct {
	Payment Payment
}

func (d *PaymentDecorator) Pay(amount float64) string {
	return d.Payment.Pay(amount)
}

// PointsPaymentDecorator 是积分支付装饰器
type PointsPaymentDecorator struct {
	*PaymentDecorator
	points float64
}

func (p *PointsPaymentDecorator) Pay(amount float64) string {
	// 计算可使用的积分
	discount := (amount / 100) * 10
	if p.points >= discount {
		// 使用积分支付部分金额
		p.points -= discount
		remainingAmount := amount - discount
		p.Payment.Pay(remainingAmount)
		return fmt.Sprintf("Paid %.2f using Credit Card and %.2f points. Remaining points: %.2f. Remaining amount to pay: %.2f", amount, discount, p.points, remainingAmount)
	}
	// 如果积分不足，继续用信用卡支付
	p.Payment.Pay(amount)
	return fmt.Sprintf("Insufficient points to apply. Paid %.2f using Credit Card", amount)
}

// CouponPaymentDecorator 是优惠券支付装饰器
type CouponPaymentDecorator struct {
	*PaymentDecorator
	couponDiscount float64
}

func (c *CouponPaymentDecorator) Pay(amount float64) string {
	// 假设每次支付可以用固定金额的优惠券
	discountedAmount := amount - c.couponDiscount
	if discountedAmount < 0 {
		discountedAmount = 0
	}
	return fmt.Sprintf("Paid %.2f using Credit Card and coupon discount of %.2f. Total paid: %.2f", amount, c.couponDiscount, discountedAmount)
}

//	func main() {
//		// 创建一个基础的信用卡支付对象
//		cardPayment := &CreditCardPayment{}
//
//		// 使用装饰器添加积分支付功能
//		pointsPayment := &PointsPaymentDecorator{
//			PaymentDecorator: &PaymentDecorator{Payment: cardPayment},
//			points:           50, // 假设用户有50积分
//		}
//
//		// 使用装饰器添加优惠券支付功能
//		finalPayment := &CouponPaymentDecorator{
//			PaymentDecorator: &PaymentDecorator{Payment: cardPayment},
//			couponDiscount:   20, // 假设有20元的优惠券
//		}
//
//		// 执行支付
//		fmt.Println(finalPayment.Pay(100))  // 总金额100，使用积分和优惠券支付
//		fmt.Println(pointsPayment.Pay(100)) //
//	}
func main() {
	// 创建基础支付对象（信用卡支付）
	cardPayment := &CreditCardPayment{}

	// 添加优惠券支付装饰器
	couponPayment := &CouponPaymentDecorator{
		PaymentDecorator: &PaymentDecorator{Payment: cardPayment},
		couponDiscount:   20, // 假设有20元的优惠券
	}

	// 添加积分支付装饰器
	pointsPayment := &PointsPaymentDecorator{
		PaymentDecorator: &PaymentDecorator{Payment: couponPayment},
		points:           50, // 假设用户有50积分
	}

	// 执行支付，金额为100元，应用20元优惠券和积分支付
	fmt.Println(pointsPayment.Pay(100))
}
