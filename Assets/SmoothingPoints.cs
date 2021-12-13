using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;
//using UnityEngine.InputSystem;
using UnityEngine.XR;

public class SmoothingPoints : MonoBehaviour
{

    public Vector3[] points;
    private LineRenderer line;

    public Transform transform;


    private void Start()
    {
        line = GetComponent<LineRenderer>();
    }
    private void Update()
    {
        Vector3[] newPoints = Generate_Points(points, 10, -4.861749f);
        line.positionCount = newPoints.Length;
        line.SetPositions(newPoints);
        Debug.Log("this is working ");
    }
    public void SetPoint(Vector3[] target)
    {
        points = target;
    }


    Vector3[] Generate_Points(Vector3[] keyPoints, int segments ,float zValue)
    {
        Vector3[] Points = new Vector3[(keyPoints.Length - 1) * segments + keyPoints.Length];
        for (int i = 1; i < keyPoints.Length; i++)
        {
            Points[(i - 1) * segments + i - 1] = new Vector3(keyPoints[i - 1].x, keyPoints[i - 1].y, 0);
            for (int j = 1; j <= segments; j++)
            {
                float x = keyPoints[i - 1].x;
                float y = keyPoints[i - 1].y;
                float z = zValue;
                float dx = (keyPoints[i].x - keyPoints[i - 1].x) / segments;
                float dy = (keyPoints[i].y - keyPoints[i - 1].y) / segments;
                Points[(i - 1) * segments + j + i - 1] = new Vector3(x + dx * j, y + dy * j, z);
            }
        }
        Points[(keyPoints.Length - 1) * segments + keyPoints.Length - 1] = new Vector3(keyPoints[keyPoints.Length - 1].x, keyPoints[keyPoints.Length - 1].y, 0);
        return Points;
    }
}
