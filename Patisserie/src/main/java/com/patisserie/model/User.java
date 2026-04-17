package com.patisserie.model;

public class User {

    private int     userId;
    private String  fullName;
    private String  email;
    private String  password;
    private String  phone;
    private String  role;            // "admin" or "customer"
    private int     failedAttempts;
    private boolean isLocked;

    public User() {}

    public int     getUserId()                  { return userId; }
    public void    setUserId(int userId)        { this.userId = userId; }

    public String  getFullName()                { return fullName; }
    public void    setFullName(String fullName) { this.fullName = fullName; }

    public String  getEmail()                   { return email; }
    public void    setEmail(String email)       { this.email = email; }

    public String  getPassword()                { return password; }
    public void    setPassword(String password) { this.password = password; }

    public String  getPhone()                   { return phone; }
    public void    setPhone(String phone)       { this.phone = phone; }

    public String  getRole()                    { return role; }
    public void    setRole(String role)         { this.role = role; }

    public int     getFailedAttempts()          { return failedAttempts; }
    public void    setFailedAttempts(int n)     { this.failedAttempts = n; }

    public boolean isLocked()                   { return isLocked; }
    public void    setLocked(boolean locked)    { this.isLocked = locked; }
}