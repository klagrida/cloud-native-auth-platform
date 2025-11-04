package com.example.authapi.controller;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    @GetMapping("/users")
    @PreAuthorize("hasRole('ADMIN')")
    public List<Map<String, Object>> getUsers() {
        List<Map<String, Object>> users = new ArrayList<>();

        Map<String, Object> user1 = new HashMap<>();
        user1.put("id", 1);
        user1.put("username", "admin");
        user1.put("email", "admin@example.com");
        user1.put("roles", List.of("USER", "ADMIN"));
        users.add(user1);

        Map<String, Object> user2 = new HashMap<>();
        user2.put("id", 2);
        user2.put("username", "user");
        user2.put("email", "user@example.com");
        user2.put("roles", List.of("USER"));
        users.add(user2);

        Map<String, Object> user3 = new HashMap<>();
        user3.put("id", 3);
        user3.put("username", "manager");
        user3.put("email", "manager@example.com");
        user3.put("roles", List.of("USER", "MANAGER"));
        users.add(user3);

        return users;
    }

    @GetMapping("/stats")
    @PreAuthorize("hasRole('ADMIN')")
    public Map<String, Object> getStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalUsers", 42);
        stats.put("activeUsers", 38);
        stats.put("totalRequests", 1523);
        stats.put("avgResponseTime", "125ms");
        stats.put("uptime", "99.9%");
        stats.put("timestamp", System.currentTimeMillis());

        Map<String, Integer> usersByRole = new HashMap<>();
        usersByRole.put("ADMIN", 3);
        usersByRole.put("USER", 42);
        usersByRole.put("MANAGER", 5);
        stats.put("usersByRole", usersByRole);

        return stats;
    }
}
