export default function ForgotPasswordPage() {
  return (
    <div className="flex h-screen items-center justify-center p-4">
      <div className="max-w-md w-full border rounded-xl p-6 shadow-sm">
        <h1 className="text-2xl font-semibold mb-4">Reset Password</h1>
        <p className="text-muted-foreground text-sm mb-6">Enter your email address and we will send you a link to reset your password.</p>
        <form className="space-y-4">
          <div>
            <label className="block text-sm font-medium mb-1">Email Address</label>
            <input type="email" className="w-full border rounded-md px-3 py-2 text-sm bg-background" />
          </div>
          <button className="w-full bg-primary text-primary-foreground py-2 rounded-md font-medium">Send Reset Link</button>
        </form>
      </div>
    </div>
  );
}
