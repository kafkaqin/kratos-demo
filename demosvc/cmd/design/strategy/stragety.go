package main

import "fmt"

// PaymentStrategy 定义支付策略接口
type PaymentStrategy interface {
	Pay(amount float64) (float64, string)
}

// CreditCardStrategy 信用卡支付策略
type CreditCardStrategy struct{}

func (c *CreditCardStrategy) Pay(amount float64) (float64, string) {
	return amount, fmt.Sprintf("Paid %.2f using Credit Card", amount)
}

// CouponStrategy 优惠券支付策略
type CouponStrategy struct {
	couponDiscount float64
}

func (c *CouponStrategy) Pay(amount float64) (float64, string) {
	discountedAmount := amount - c.couponDiscount
	if discountedAmount < 0 {
		discountedAmount = 0
	}
	return discountedAmount, fmt.Sprintf("Applied coupon discount of %.2f. Remaining amount: %.2f", c.couponDiscount, discountedAmount)
}

// PointsStrategy 积分支付策略
type PointsStrategy struct {
	points float64
}

func (p *PointsStrategy) Pay(amount float64) (float64, string) {
	// 计算可使用的积分（每100元抵10元）
	discount := (amount / 100) * 10
	if p.points >= discount {
		p.points -= discount
		remainingAmount := amount - discount
		return remainingAmount, fmt.Sprintf("Used %.2f points. Remaining amount: %.2f. Remaining points: %.2f", discount, remainingAmount, p.points)
	}
	return amount, "Insufficient points to apply."
}

// PaymentContext 支付上下文
type PaymentContext struct {
	strategies []PaymentStrategy
}

// AddStrategy 添加支付策略
func (pc *PaymentContext) AddStrategy(strategy PaymentStrategy) {
	pc.strategies = append(pc.strategies, strategy)
}

// Pay 执行支付流程
func (pc *PaymentContext) Pay(amount float64) (float64, string) {
	remainingAmount := amount
	var paymentDetails string

	// 按优先级依次应用支付策略
	for _, strategy := range pc.strategies {
		var detail string
		remainingAmount, detail = strategy.Pay(remainingAmount)
		paymentDetails += detail + " "

		// 如果金额已经降为0，则停止继续支付
		if remainingAmount <= 0 {
			break
		}
	}

	return remainingAmount, paymentDetails
}

func main() {
	// 创建支付上下文
	paymentContext := &PaymentContext{}

	// 添加支付策略（按优先级）
	paymentContext.AddStrategy(&CouponStrategy{couponDiscount: 20}) // 优先使用优惠券
	paymentContext.AddStrategy(&PointsStrategy{points: 50})         // 其次使用积分
	paymentContext.AddStrategy(&CreditCardStrategy{})               // 最后使用信用卡

	// 执行支付
	remainingAmount, details := paymentContext.Pay(100)
	fmt.Println("Payment Details:", details)
	fmt.Printf("Remaining Amount: %.2f\n", remainingAmount)
}
